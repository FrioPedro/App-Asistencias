// lib/domain/sync/activity_sync_service.dart
import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/core/enpoinService.dart';
import 'package:app_asistencias/domain/connectivity/network_info.dart';
import 'package:app_asistencias/domain/user/get_user.dart';
import 'package:app_asistencias/models/activity_model.dart';
import 'package:isar/isar.dart';

class ActivitySyncService {
  final NetworkInfo _net;
  static bool _running = false;

  ActivitySyncService({NetworkInfo? net}) : _net = net ?? NetworkInfo();

  DateTime _floorToSecond(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);

  /// Dedup por dedupKey:
  /// - si hay repetidos, gana isSynced=true
  /// - si empatan, gana el más reciente por timestamp
  List<ActivityModel> _dedupeByDedupKey(List<ActivityModel> list) {
    final Map<String, ActivityModel> byKey = {};

    for (final a in list) {
      final key = a.dedupKey;

      if (!byKey.containsKey(key)) {
        byKey[key] = a;
        continue;
      }

      final existing = byKey[key]!;

      // 1) synced gana
      if (existing.isSynced != true && a.isSynced == true) {
        byKey[key] = a;
        continue;
      }

      // 2) si ambos synced o ambos pending -> gana más reciente
      if ((existing.isSynced == a.isSynced) &&
          a.timestamp.isAfter(existing.timestamp)) {
        byKey[key] = a;
      }
    }

    return byKey.values.toList();
  }

  void _printLastStateByService(Map<int, List<ActivityModel>> byService) {
    print('--- LAST STATE BY SERVICE ---');

    byService.forEach((sid, activities) {
      if (activities.isEmpty) return;

      activities.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final last = activities.last;
      final isActive = last.motive == MotiveType.entry;

      print(
        'Servicio $sid → '
        'ESTADO=${isActive ? "ACTIVO" : "CERRADO"} | '
        'ultimo=${last.motive.label} | '
        'timestamp=${last.timestamp} | '
        'synced=${last.isSynced} | '
        'dedupKey=${last.dedupKey}',
      );
    });
  }

  /// Wi-Fi o datos móviles
  Future<void> syncIfPossible() async {
    if (_running) {
      print('[SYNC] Skipped: already running');
      return;
    }
    _running = true;

    try {
      print('[SYNC] syncIfPossible called');

      final connected = await _net.hasConnection();
      print('[SYNC] Connectivity: ${connected ? "CONNECTED" : "NO CONNECTION"}');

      if (!connected) {
        print('[SYNC] Aborting sync: no connection');
        return;
      }

      await syncPending();
    } finally {
      _running = false;
    }
  }

  Future<void> syncPending({int batchSize = 100}) async {
    print('[SYNC] syncPending started');

    final isar = await Database.instance();
    final api = EndpointService.instance;

    final user =
        await GetUser.getUserLocal() ?? await GetUser.fetchAndStoreUser();

    if (user == null) {
      print('[SYNC] No user found, aborting');
      return;
    }

    print('[SYNC] User loaded: nationalId=${user.nationalId}, zone=${user.zone}');

    // 1) Cargar TODO local (synced + pending)
    final allLocal = await isar.activityModels.where().findAll();

    // 2) Normalizar timestamps a segundos (evita microsegundos raros)
    for (final a in allLocal) {
      a.timestamp = _floorToSecond(a.timestamp);
      // IMPORTANTE: si tu dedupKey depende del timestamp, idealmente deberías
      // tener ya dedupKey construido con timestamp sin microsegundos desde el modelo.
      // Si NO es así, esta dedupe no será fiable.
    }

    // 3) Dedupe global (fuente de verdad para estado y para envío)
    final canonical = _dedupeByDedupKey(allLocal)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // 4) Agrupar canonical por servicio y print de estado (ACTIVO/CERRADO)
    final Map<int, List<ActivityModel>> byService = {};
    for (final a in canonical) {
      final sid = a.serverId;
      if (sid == null) continue;
      (byService[sid] ??= <ActivityModel>[]).add(a);
    }
    _printLastStateByService(byService);

    // 5) Prevención clave:
    //    pending a enviar = canonical donde isSynced=false
    //    (esto automáticamente descarta duplicates que ya tienen synced=true con mismo dedupKey)
    final canonicalPending = canonical.where((a) => a.isSynced != true).toList();

    print('[SYNC] Local total=${allLocal.length} canonical=${canonical.length} pendingCanonical=${canonicalPending.length}');

    // 6) (Opcional recomendado) Purga duplicados físicos en Isar (deja solo canonical)
    await isar.writeTxn(() async {
      final keepIds = canonical.map((e) => e.id).toSet();
      final toDelete = allLocal
          .where((a) => !keepIds.contains(a.id))
          .map((a) => a.id)
          .toList();

      if (toDelete.isNotEmpty) {
        await isar.activityModels.deleteAll(toDelete);
        print('[SYNC] Purged duplicates in Isar: ${toDelete.length}');
      }
    });

    // 7) Batch de envío
    final pendingBatch = canonicalPending.take(batchSize).toList();

    if (pendingBatch.isEmpty) {
      print('[SYNC] No pending activities');
      return;
    }

    print('[SYNC] Sending ${pendingBatch.length} activities');

    for (final a in pendingBatch) {
      a.timestamp = _floorToSecond(a.timestamp);

      print('[SYNC] Sending activity project=${a.serverId}, motive=${a.motive.label}, timestamp=${a.timestamp}, dedupKey=${a.dedupKey}');

      try {
        final payload = a.toMarkPayload(
          project: a.serverId ?? 0,
          collaboratorId: user.nationalId ?? '',
          zone: user.zone ?? '',
          timestamp: a.timestamp,
        );

        print('[SYNC] Payload: $payload');

        final res = await api.post('/api/attendance/v2', data: payload);

        print('[SYNC] Response status: ${res.statusCode}');

        if (res.statusCode == 200 || res.statusCode == 201) {
          await isar.writeTxn(() async {
            final fresh = await isar.activityModels.get(a.id);
            if (fresh != null) {
              fresh.isSynced = true;
              fresh.timestamp = _floorToSecond(fresh.timestamp);
              await isar.activityModels.put(fresh);
            }
          });

          print('[SYNC] Activity marked as synced');
        } else {
          print('[SYNC] Server returned ${res.statusCode}, activity remains pending');
        }
      } catch (e) {
        print('[SYNC] Error sending activity: $e');
      }
    }

    print('[SYNC] syncPending finished');
  }
}
