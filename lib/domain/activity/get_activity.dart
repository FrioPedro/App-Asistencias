import 'package:isar/isar.dart';

import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/core/enpoinService.dart';
import 'package:app_asistencias/models/activity_model.dart';

class GetActivity {
  /// Últimas 20 actividades locales, ordenadas de más antigua -> más nueva
  static Future<List<ActivityModel>> getLocalData() async {
    final isar = await Database.instance();

    final recent = await isar.activityModels
        .where()
        .sortByTimestampDesc()
        .findAll();

    return recent.reversed.toList();
  }

  /// Últimas 20 actividades locales por asignación (serverId), ordenadas de más antigua -> más nueva
  static Future<List<ActivityModel>> getActivityByAssignment(int serverId) async {
    final isar = await Database.instance();

    final recent = await isar.activityModels
        .filter()
        .serverIdEqualTo(serverId)
        .sortByTimestampDesc()
        .limit(20)
        .findAll();

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

  /// Asignación está "activa" si el ÚLTIMO registro es MotiveType.entry
  static Future<ActivityModel?> getActive(int serverId) async {
    final isar = await Database.instance();

    final last = await isar.activityModels
        .filter()
        .serverIdEqualTo(serverId)
        .sortByTimestampDesc()
        .findFirst();

    if (last == null) return null;

    return (last.motive == MotiveType.entry) ? last : null;
  }

  static Future<bool> isActive(int serverId) async {
    return (await getActive(serverId)) != null;
  }

  /// Extra: lista de pendientes de sincronizar
  static Future<List<ActivityModel>> getPendingSync({int limit = 100}) async {
    final isar = await Database.instance();

    return isar.activityModels
        .filter()
        .isSyncedEqualTo(false)
        .sortByTimestamp()
        .limit(limit)
        .findAll();
  }
}
