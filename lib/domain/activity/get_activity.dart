import 'package:app_asistencias/models/activity/motiveActivity_model.dart';
import 'package:isar/isar.dart';

import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/core/enpoinService.dart';
import 'package:app_asistencias/models/activity/activity_model.dart';

class GetActivity {
  static Future<List<ActivityModel>> getLocalData() async {
    final isar = await Database.instance();

    final recent =
        await isar.activityModels.where().sortByTimestamp().findAll();

    return recent.reversed.toList();
  }

  static Future<List<ActivityModel>> getOnlineData() async {
    final apiService = EndpointService.instance;

    try {
      final response = await apiService.get('/api/schedule');
      final raw = response.data;

      final List<dynamic> data = raw is List ? raw : <dynamic>[];

      print("[GET ACTIVITY ONLINE] Status: ${response.statusCode}");
      if (data.isNotEmpty && data.first is Map) {
        final first = data.first as Map;
        print("[GET ACTIVITY ONLINE] First Document: ${first["Document"]}");
      }

      final parsed = data
          .whereType<Map>() // asegura Map<dynamic,dynamic>
          .map((m) => Map<String, dynamic>.from(m))
          .map<ActivityModel>((json) => ActivityModel.fromServer(json))
          .toList();

      print("[GET ACTIVITY ONLINE] Total actividades: ${parsed.length}");

      return parsed;
    } catch (e) {
      print("[GET ACTIVITY ONLINE] Error: $e");
      return [];
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

  static Future<List<ActivityModel>> getOnlineAndLocalPending({
    int pendingLimit = 100,
  }) async {
    // 1) Obtener ambas fuentes en paralelo
    final results = await Future.wait([
      getOnlineData(),
      getPendingSync(limit: pendingLimit),
    ]);

    final online = results[0];
    final localPending = results[1];

    // 2) Unir listas
    final combined = <ActivityModel>[
      ...online,
      ...localPending,
    ];

    if (combined.isEmpty) return [];

    // 3) Ordenar por timestamp DESC (más nuevo primero)
    combined.sort((a, b) {
      final ta = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tb = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      return tb.compareTo(ta); // DESC
    });

    return combined;
  }
}
