// lib/domain/sync/activity_sync_service.dart
import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/core/enpoinService.dart';
import 'package:app_asistencias/domain/connectivity/network_info.dart';
import 'package:app_asistencias/domain/user/get_user.dart';
import 'package:app_asistencias/models/activity_model.dart';
import 'package:isar/isar.dart';

class ActivitySyncService {
  final NetworkInfo _net;

  ActivitySyncService({NetworkInfo? net}) : _net = net ?? NetworkInfo();

  /// Wi-Fi o datos móviles
  Future<void> syncIfPossible() async {
    print('[SYNC] syncIfPossible called');

    final connected = await _net.hasConnection();
    print('[SYNC] Connectivity: ${connected ? "CONNECTED" : "NO CONNECTION"}');

    if (!connected) {
      print('[SYNC] Aborting sync: no connection');
      return;
    }

    await syncPending();
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

    print(
        '[SYNC] User loaded: nationalId=${user.nationalId}, zone=${user.zone}');

    final allPending = await isar.activityModels
        .filter()
        .isSyncedEqualTo(false)
        .sortByTimestamp()
        .findAll();

    print('[SYNC] Total pending activities: ${allPending.length}');

    final pending = allPending.take(batchSize).toList();

    if (pending.isEmpty) {
      print('[SYNC] No pending activities');
      return;
    }

    print('[SYNC] Sending ${pending.length} activities');

    for (final a in pending) {
      print(
          '[SYNC] Sending activity project=${a.serverId}, motive=${a.motive.label}, timestamp=${a.timestamp}');

      try {
        final payload = a.toMarkPayload(
          project: a.serverId ?? 0,
          collaboratorId: user.nationalId ?? '',
          zone: user.zone ?? '',
        );

        print('[SYNC] Payload: $payload');

        final res =
            await api.post('/api/attendance/v2', data: payload);

        print('[SYNC] Response status: ${res.statusCode}');

        if (res.statusCode == 200 || res.statusCode == 201) {
          await isar.writeTxn(() async {
            a.isSynced = true;
            await isar.activityModels.put(a);
          });

          print('[SYNC] Activity marked as synced');
        } else {
          print(
              '[SYNC] Server returned ${res.statusCode}, activity remains pending');
        }
      } catch (e) {
        print('[SYNC] Error sending activity: $e');
      }
    }

    print('[SYNC] syncPending finished');
  }
}
