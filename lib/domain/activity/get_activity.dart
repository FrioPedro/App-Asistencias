import 'package:app_asistencias/models/activity/motiveActivity_model.dart';
import 'package:isar/isar.dart';

import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/core/enpoinService.dart';
import 'package:app_asistencias/models/activity/activity_model.dart';
import 'package:app_asistencias/domain/connectivity/network_info.dart';

class GetActivity {
  static Future<List<ActivityModel>> getLocalData() async {
    final isar = await Database.instance();

    final recent =
        await isar.activityModels.where().sortByTimestamp().findAll();

    return recent.reversed.toList();
  }

  /// Descarga el historial del servidor y lo persiste en Isar (upsert por keyGroup).
  /// Llama a esto al abrir el historial o al hacer login para que los
  /// registros previos a la instalación de la app queden disponibles offline.
  static Future<void> syncOnlineToLocal() async {
    // No intentar si no hay red
    final connected = await NetworkInfo().hasConnection();
    if (!connected) {
      print('[SYNC_DOWN] Sin conexión, omitiendo descarga de historial');
      return;
    }

    final apiService = EndpointService.instance;
    final isar = await Database.instance();

    try {
      final response = await apiService.get('/api/schedule');
      final raw = response.data;

      print('[SYNC_DOWN] Status: ${response.statusCode}');
      print('[SYNC_DOWN] Raw type: ${raw.runtimeType}');

      final List<dynamic> data = raw is List ? raw : <dynamic>[];

      print('[SYNC_DOWN] Registros recibidos del server: ${data.length}');

      // Imprimir el primer registro para ver la estructura real
      if (data.isNotEmpty && data.first is Map) {
        print('[SYNC_DOWN] ===== PRIMER REGISTRO RAW =====');
        final first = Map<String, dynamic>.from(data.first as Map);
        first.forEach(
            (k, v) => print('[SYNC_DOWN]   "$k" => $v (${v.runtimeType})'));
        print('[SYNC_DOWN] ===============================');
      }

      if (data.isEmpty) return;

      final serverRecords = data
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .map<ActivityModel?>((json) {
            try {
              return ActivityModel.fromServer(json);
            } catch (e) {
              print(
                  '[SYNC_DOWN] Error parseando registro: $e | JSON keys: ${json.keys.toList()}');
              return null;
            }
          })
          .whereType<ActivityModel>()
          .toList();

      print('[SYNC_DOWN] Registros parseados OK: ${serverRecords.length}');
      if (serverRecords.isNotEmpty) {
        final first = serverRecords.first;
        print(
            '[SYNC_DOWN] Primer parsed: keyGroup="${first.keyGroup}" doc="${first.documentId}" ts=${first.timestamp} motive=${first.motiveActivity}');
      }

      await isar.writeTxn(() async {
        for (final remote in serverRecords) {
          final key = (remote.keyGroup ?? '').trim();
          if (key.isEmpty) continue;

          // Buscar si ya existe localmente por keyGroup
          final existing = await isar.activityModels
              .filter()
              .keyGroupEqualTo(key)
              .findFirst();

          if (existing != null) {
            // Ya existe: solo actualizar campos que el server puede haber completado
            // (conservamos isSynced y coordenadas GPS locales si el server no las tiene)
            existing.documentId ??= remote.documentId;
            existing.client ??= remote.client;
            existing.description ??= remote.description;
            existing.latitude ??= remote.latitude;
            existing.longitude ??= remote.longitude;
            await isar.activityModels.put(existing);
          } else {
            // Registro nuevo (previo a la app): insertar
            await isar.activityModels.put(remote);
          }
        }
      });

      print('[SYNC_DOWN] Upsert completado en Isar');
    } catch (e) {
      print('[SYNC_DOWN] Error descargando historial: $e');
    }
  }

  static Future<ActivityModel?> getActive(String keyGroup) async {
    final isar = await Database.instance();

    // Buscamos la más reciente que tenga ese keyGroup
    final last = await isar.activityModels
        .filter()
        .keyGroupEqualTo(keyGroup)
        .sortByTimestampDesc()
        .findFirst();

    if (last == null) return null;
    if (last.motiveActivity == MotiveActivity.endWork) return null;

    return last;
  }

  /// Extra: lista de pendientes de sincronizar
  static Future<List<ActivityModel>> getPendingSync({int limit = 100}) async {
    final isar = await Database.instance();

    return isar.activityModels
        .filter()
        .isSyncedEqualTo(false)
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
  }
}
