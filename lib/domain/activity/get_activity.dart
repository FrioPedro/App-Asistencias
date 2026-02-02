import 'package:isar/isar.dart';

import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/core/enpoinService.dart';
import 'package:app_asistencias/models/activity_model.dart';

class GetActivity {
  /// Últimas 20 actividades locales, ordenadas de más antigua -> más nueva
  static Future<List<ActivityModel>> getLocalData() async {
    final isar = await Database.instance();

    final recent =
        await isar.activityModels.where().sortByEntryTimestamp().findAll();

    return recent.reversed.toList();
  }

  /// Últimas 20 actividades locales por asignación (serverId), ordenadas de más antigua -> más nueva
  static Future<List<ActivityModel>> getActivityByAssignment(
      int serverId) async {
    final isar = await Database.instance();

    final recent = await isar.activityModels
        .filter()
        .serverIdEqualTo(serverId)
        .sortByEntryTimestampDesc()
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

  /// Asignación está "activa" si EXISTE una sesión ABIERTA (exitTimestamp == null)
  /// Se asume que solo puede haber 1 abierta por serverId.
  static Future<ActivityModel?> getActive(int serverId) async {
    final isar = await Database.instance();

    // Buscamos la más reciente que tenga ese ServerID
    final last = await isar.activityModels
        .filter()
        .serverIdEqualTo(serverId)
        .sortByEntryTimestampDesc()
        .findFirst();

    if (last == null) return null;

    // Si la última actividad NO tiene timestamp de salida, está abierta.
    return (last.exitTimestamp == null) ? last : null;
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
        .sortByEntryTimestamp()
        .limit(limit)
        .findAll();
  }

  static List<ActivityModel> dedupeActivities(List<ActivityModel> list) {
    final Map<String, ActivityModel> byKey = {};

    for (final a in list) {
      // Usamos el Token como Deduplicación Primaria
      final key = a.token;

      if (!byKey.containsKey(key)) {
        byKey[key] = a;
        continue;
      }

      final existing = byKey[key]!;

      // Prioridad: synced gana sobre pending
      if (existing.isSynced != true && a.isSynced == true) {
        byKey[key] = a;
        continue;
      }

      if ((existing.isSynced == a.isSynced) &&
          a.entryTimestamp.isAfter(existing.entryTimestamp)) {
        byKey[key] = a;
      }
    }

    return byKey.values.toList();
  }

  static Future<List<ActivityModel>> syncOnline() async {
    // Método legacy/debug que imprime info
    final online = await getOnlineData();
    print('--- ONLINE DATA (${online.length}) ---');
    for (var a in online) {
      print('Token: ${a.token} | Open: ${a.isOpen} | Synced: ${a.isSynced}');
    }
    return [];
  }

  static Future<List<ActivityModel>> syncOnlineToLocal() async {
    try {
      final online = await getOnlineData();
      if (online.isEmpty) return await getLocalData();

      final isar = await Database.instance();

      await isar.writeTxn(() async {
        for (final activity in online) {
          // 1. Buscar por TOKEN (Identidad fuerte)
          ActivityModel? match = await isar.activityModels
              .filter()
              .tokenEqualTo(activity.token)
              .findFirst();

          // 2. Si no hay token match (migración?), buscar por Fuzzy Logic con ServerId + Time
          if (match == null && activity.serverId != null) {
            final windowStart =
                activity.entryTimestamp.subtract(const Duration(hours: 12));
            final windowEnd =
                activity.entryTimestamp.add(const Duration(hours: 12));

            match = await isar.activityModels
                .filter()
                .serverIdEqualTo(activity.serverId)
                .entryTimestampBetween(windowStart, windowEnd)
                .findFirst();
          }

          // Si encontramos match, actualizamos el existente manteniendo su ID local
          if (match != null) {
            activity.id = match.id;
          }

          await isar.activityModels.put(activity);
        }
      });

      return await getLocalData();
    } catch (e) {
      print("[SYNC ERROR] $e");
      return await getLocalData();
    }
  }
}
