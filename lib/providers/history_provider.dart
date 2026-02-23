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
    // 1) Subir pendientes al servidor (local → server)
    await _sync.syncIfPossible();

    // 2) Bajar historial del servidor y persistir en Isar (server → local)
    //    Esto permite ver registros anteriores a la instalación de la app.
    await GetActivity.syncOnlineToLocal();

    // 3) Leer todo desde la BD local (incluye histórico descargado + registros offline)
    final events = await GetActivity.getLocalData();
    return groupByKeyGroup(events);
  }
}
