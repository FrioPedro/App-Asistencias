import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/core/enpoinService.dart';
import 'package:app_asistencias/domain/connectivity/network_info.dart';
import 'package:app_asistencias/domain/user/get_user.dart';
import 'package:app_asistencias/models/activity/activity_model.dart';
import 'package:app_asistencias/domain/activity/get_activity.dart';
import 'package:isar/isar.dart';

class ActivitySyncService {
  final NetworkInfo _net;
  static bool _running = false;

  ActivitySyncService({NetworkInfo? net}) : _net = net ?? NetworkInfo();

  Future<void> syncIfPossible() async {
    if (_running) {
      print('[SYNC] Skipped: already running');
      return;
    }
    _running = true;

    try {
      final connected = await _net.hasConnection();
      if (!connected) {
        print('[SYNC] Aborting: no connection');
        return;
      }

      await syncPending();
    } finally {
      _running = false;
    }
  }

  Future<void> syncPending({int batchSize = 100}) async {
    final isar = await Database.instance();
    final api = EndpointService.instance;

    final user =
        await GetUser.getUserLocal() ?? await GetUser.fetchAndStoreUser();

    if (user == null) {
      print('[SYNC] No user found, aborting');
      return;
    }

    // 1) Cargar pendientes (orden cronológico recomendado)
    final pending = await GetActivity.getPendingSync();

    if (pending.isEmpty) {
      print('[SYNC] No pending activities');
      return;
    }

    print('[SYNC] Sending ${pending.length} activities');

    for (final a in pending) {
      try {
        // 2) Payload directo (1 request por actividad)
        final payload = a.toServerPayload();

        // Si tu server requiere keys/token, agrégalo aquí:
        // payload['keys'] = a.keyGroup;

        // Si collaborator puede venir null, fuerza desde user
        payload['collaborator'] ??= user.nationalId ?? '';

        final res = await api.post('/api/attendance/v2', data: payload);

        final ok = res.statusCode == 200 || res.statusCode == 201;
        if (!ok) {
          print('[SYNC] Failed ${a.id}: ${res.statusCode}');
          continue;
        }

        // 3) Marcar como sincronizado
        await isar.writeTxn(() async {
          final fresh = await isar.activityModels.get(a.id);
          if (fresh != null) {
            fresh.isSynced = true;
            await isar.activityModels.put(fresh);
          }
        });

        print('[SYNC] Synced OK id=${a.id} keyGroup=${a.keyGroup}');
      } catch (e) {
        print('[SYNC] Error sending id=${a.id}: $e');
      }
    }

    print('[SYNC] syncPending finished');
  }
}
