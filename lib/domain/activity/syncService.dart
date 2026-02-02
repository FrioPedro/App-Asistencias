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

  List<ActivityModel> _dedupeByToken(List<ActivityModel> list) {
    final Map<String, ActivityModel> byKey = {};

    for (final a in list) {
      final key = a.token;

      if (!byKey.containsKey(key)) {
        byKey[key] = a;
        continue;
      }

      final existing = byKey[key]!;

      // Si ambos existen, nos quedamos con el que tenga más datos (ej. cerrado vs abierto)
      if (a.isClosed && !existing.isClosed) {
        byKey[key] = a;
      }
    }

    return byKey.values.toList();
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

    // 1) Cargar pendientes
    final pendingModels =
        await isar.activityModels.filter().isSyncedEqualTo(false).findAll();

    if (pendingModels.isEmpty) {
      print('[SYNC] No pending activities');
      return;
    }

    print('[SYNC] Sending ${pendingModels.length} activities');

    for (final a in pendingModels) {
      try {
        // --- LÓGICA DE DOBLE ENVÍO PARA SESIONES COMPLETAS OFFLINE ---
        // Si la sesión está CERRADA, debemos garantizar que el server tenga la ENTRADA primero.
        // Como no sabemos si la entrada ya se envió (isSynced es un solo bool),
        // Por seguridad, enviamos ENTRADA primero. Si el server es idempotente (upsert), no pasa nada.

        bool success = true;

        // 1. Enviar ENTRADA (Motive 1)
        // Forzamos "isOpen" visualmente para generar payload de entrada??
        // No, el toMarkPayload usa "isClosed" para decidir.
        // Haremos un truco: generamos payload manual o modificamos toMarkPayload?
        // Mejor: Construimos payload manualmente aquí para tener control absoluto.

        final basePayload = {
          'token': a.token,
          'project': a.serverId ?? 0,
          'collaborator': user.nationalId ?? '',
          'zone': user.zone ?? '',
          'task': a.task.id,
        };

        // PAYLOAD 1: ENTRADA
        final payloadEntry = {
          ...basePayload,
          'motive': 1,
          'latitude': a.entryLatitude,
          'longitude': a.entryLongitude,
          'timestamp': a.entryTimestamp
              .toIso8601String()
              .replaceFirst('T', ' ')
              .split('.')
              .first,
        };

        print('[SYNC] Sending ENTRY for ${a.token}...');
        final resEntry =
            await api.post('/api/attendance/v2', data: payloadEntry);

        if (resEntry.statusCode != 200 && resEntry.statusCode != 201) {
          print('[SYNC] Entry failed: ${resEntry.statusCode}');
          success = false;
        }

        // 2. Si está CERRADA y Entry fue ok, enviar SALIDA (Motive 2)
        if (success && a.isClosed) {
          final payloadExit = {
            ...basePayload,
            'motive': 2,
            'latitude': a.exitLatitude,
            'longitude': a.exitLongitude,
            'timestamp': a.exitTimestamp!
                .toIso8601String()
                .replaceFirst('T', ' ')
                .split('.')
                .first,
          };

          print('[SYNC] Sending EXIT for ${a.token}...');
          final resExit =
              await api.post('/api/attendance/v2', data: payloadExit);

          if (resExit.statusCode != 200 && resExit.statusCode != 201) {
            print('[SYNC] Exit failed: ${resExit.statusCode}');
            success = false;
          }
        }

        // 3. Si todo OK, marcar synced
        if (success) {
          await isar.writeTxn(() async {
            final fresh = await isar.activityModels.get(a.id);
            if (fresh != null) {
              fresh.isSynced = true;
              await isar.activityModels.put(fresh);
            }
          });
          print('[SYNC] Synced success: ${a.token}');
        }
      } catch (e) {
        print('[SYNC] Error sending activity ${a.token}: $e');
      }
    }

    print('[SYNC] syncPending finished');
  }
}
