// Para debugPrint
import 'package:app_asistencias/models/activity/activity_model.dart';
import 'package:app_asistencias/domain/activity/get_activity.dart';
import 'package:app_asistencias/domain/activity/syncService.dart';
import 'package:app_asistencias/models/activity/activity_model.dart';
import 'package:app_asistencias/models/taskType_model.dart';
import 'package:app_asistencias/models/assigment_model.dart';
import 'package:app_asistencias/models/user/user_zone.dart';
import 'package:app_asistencias/models/activity/motiveActivity_model.dart';

class ActivitySession {
  final String keyGroup;
  final int assigmentId;
  final String? documentId;
  final String? client;
  final String? description;
  final TaskType task;
  final AssigmentType activityType;
  final UserZone zone;

  final DateTime entryTimestamp;
  final DateTime? exitTimestamp;

  final bool hasPendingSync;

  ActivitySession({
    required this.keyGroup,
    required this.assigmentId,
    required this.task,
    required this.activityType,
    required this.zone,
    required this.entryTimestamp,
    this.exitTimestamp,
    this.documentId,
    this.client,
    this.description,
    required this.hasPendingSync,
  });
}

List<ActivitySession> groupByKeyGroup(List<ActivityModel> events) {
  print('📦 groupByKeyGroup → eventos recibidos: ${events.length}');
  final Map<String, _Acc> map = {};

  for (final e in events) {
    final key = (e.keyGroup ?? '').trim();

    if (key.isEmpty || key == "") continue;

    print(
      '➡️ Evento | keyGroup="$key" '
      '| motive=${e.motiveActivity} '
      '| ts=${e.assigmentId} '
      '| synced=${e.isSynced}',
    );

    final ts = e.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);

    final acc = map.putIfAbsent(
      key,
      () {
        print('🆕 Nuevo _Acc para keyGroup="$key"');
        return _Acc(
          keyGroup: key,
          assigmentId: e.assigmentId,
          documentId: e.documentId,
          client: e.client,
          description: e.description,
          task: e.task,
          activityType: e.activityType,
          zone: e.zone,
        );
      },
    );
    // meta (por si vienen null en un evento y no en otro)
    acc.documentId ??= e.documentId;
    acc.client ??= e.client;
    acc.description ??= e.description;
    acc.task = e.task;
    acc.activityType = e.activityType;
    acc.zone = e.zone;

    if (!e.isSynced) acc.hasPendingSync = true;

    if (e.motiveActivity == MotiveActivity.startWork) {
      // la entrada más antigua
      if (acc.entry == null || ts.isBefore(acc.entry!)) acc.entry = ts;
    } else if (e.motiveActivity == MotiveActivity.endWork) {
      // la salida más reciente
      if (acc.exit == null || ts.isAfter(acc.exit!)) acc.exit = ts;
      // si no hubo entry, al menos algo
      acc.entry ??= ts;
    }
  }

  final sessions = map.values
      .where((a) => a.entry != null)
      .map((a) => ActivitySession(
            keyGroup: a.keyGroup,
            assigmentId: a.assigmentId,
            documentId: a.documentId,
            client: a.client,
            description: a.description,
            task: a.task,
            activityType: a.activityType,
            zone: a.zone,
            entryTimestamp: a.entry!,
            exitTimestamp: a.exit,
            hasPendingSync: a.hasPendingSync,
          ))
      .toList();

  // Orden: más reciente primero (por último evento en la sesión)
  DateTime lastOf(ActivitySession s) => s.exitTimestamp ?? s.entryTimestamp;

  sessions.sort((a, b) => lastOf(b).compareTo(lastOf(a)));

  return sessions;
}

/// ============================================================================
/// groupNoKeyGroup - Agrupa eventos SIN keyGroup (legacy/antiguos)
/// ============================================================================
/// Para eventos anteriores a la implementación de keyGroup, esta función
/// empareja Entradas y Salidas cronológicamente por assigmentId.
/// ============================================================================
List<ActivitySession> groupNoKeyGroup(List<ActivityModel> events) {
  print('📦 groupNoKeyGroup → eventos recibidos: ${events.length}');

  // 1. Filtrar SOLO eventos sin keyGroup
  final noKeyEvents = events.where((e) {
    final key = (e.keyGroup ?? '').trim();
    return key.isEmpty; // Solo los que NO tienen key
  }).toList();

  print('🔍 Eventos sin keyGroup: ${noKeyEvents.length}');

  if (noKeyEvents.isEmpty) return [];

  // 2. Ordenar cronológicamente (más antiguo primero)
  noKeyEvents.sort((a, b) {
    final ta = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
    final tb = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
    return ta.compareTo(tb); // ASC
  });

  // 3. Agrupar por assigmentId, emparejando Entrada→Salida
  final List<ActivitySession> sessions = [];

  // Mapa para tracking: assigmentId -> lista de entradas pendientes de cerrar
  final Map<int, List<_LegacyEntry>> pendingEntries = {};

  for (final event in noKeyEvents) {
    final assigmentId = event.assigmentId;
    final ts = event.timestamp ?? DateTime.now();

    if (event.motiveActivity == MotiveActivity.startWork) {
      // Es una ENTRADA: guardarla como pendiente
      pendingEntries.putIfAbsent(assigmentId, () => []);
      pendingEntries[assigmentId]!.add(_LegacyEntry(
        event: event,
        timestamp: ts,
      ));
      print('➡️ Entrada detectada: assigmentId=$assigmentId, ts=$ts');
    } else if (event.motiveActivity == MotiveActivity.endWork) {
      // Es una SALIDA: buscar la entrada más reciente sin cerrar
      final entries = pendingEntries[assigmentId];

      if (entries != null && entries.isNotEmpty) {
        // Tomar la entrada más antigua pendiente (FIFO)
        final matchedEntry = entries.removeAt(0);

        // Generar un keyGroup sintético para mantener compatibilidad
        final syntheticKey =
            'LEGACY_${assigmentId}_${matchedEntry.timestamp.millisecondsSinceEpoch}';

        sessions.add(ActivitySession(
          keyGroup: syntheticKey,
          assigmentId: assigmentId,
          documentId: matchedEntry.event.documentId ?? event.documentId,
          client: matchedEntry.event.client ?? event.client,
          description: matchedEntry.event.description ?? event.description,
          task: matchedEntry.event.task,
          activityType: matchedEntry.event.activityType,
          zone: matchedEntry.event.zone,
          entryTimestamp: matchedEntry.timestamp,
          exitTimestamp: ts,
          hasPendingSync: !matchedEntry.event.isSynced || !event.isSynced,
        ));

        print(
            '✅ Sesión creada: $syntheticKey (${matchedEntry.timestamp} → $ts)');
      } else {
        // Salida huérfana (sin entrada correspondiente)
        print('⚠️ Salida huérfana detectada: assigmentId=$assigmentId, ts=$ts');
      }
    }
  }

  // 4. Crear sesiones para entradas que quedaron sin cerrar (en curso)
  for (final entry in pendingEntries.entries) {
    final assigmentId = entry.key;
    for (final pending in entry.value) {
      final syntheticKey =
          'LEGACY_OPEN_${assigmentId}_${pending.timestamp.millisecondsSinceEpoch}';

      sessions.add(ActivitySession(
        keyGroup: syntheticKey,
        assigmentId: assigmentId,
        documentId: pending.event.documentId,
        client: pending.event.client,
        description: pending.event.description,
        task: pending.event.task,
        activityType: pending.event.activityType,
        zone: pending.event.zone,
        entryTimestamp: pending.timestamp,
        exitTimestamp: null, // Sin cerrar
        hasPendingSync: !pending.event.isSynced,
      ));

      print('🔓 Sesión abierta (legacy): $syntheticKey');
    }
  }

  // 5. Ordenar: más reciente primero
  sessions.sort((a, b) {
    final aLast = a.exitTimestamp ?? a.entryTimestamp;
    final bLast = b.exitTimestamp ?? b.entryTimestamp;
    return bLast.compareTo(aLast); // DESC
  });

  print('📊 Total sesiones legacy generadas: ${sessions.length}');
  return sessions;
}

/// Clase auxiliar para tracking de entradas legacy pendientes
class _LegacyEntry {
  final ActivityModel event;
  final DateTime timestamp;

  _LegacyEntry({required this.event, required this.timestamp});
}

class _Acc {
  final String keyGroup;
  final int assigmentId;

  String? documentId;
  String? client;
  String? description;

  TaskType task;
  AssigmentType activityType;
  UserZone zone;

  DateTime? entry;
  DateTime? exit;

  bool hasPendingSync = false;

  _Acc({
    required this.keyGroup,
    required this.assigmentId,
    this.documentId,
    this.client,
    this.description,
    required this.task,
    required this.activityType,
    required this.zone,
  });
}

class HistoryProvider {
  final ActivitySyncService _sync = ActivitySyncService();

  Future<List<ActivitySession>> fetchHistory() async {
    await _sync.syncIfPossible();

    final events = await GetActivity.getOnlineAndLocalPending(); // eventos
    return groupByKeyGroup(events); // sesiones
  }
}
