import 'package:isar/isar.dart';

import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/core/enpoinService.dart';
import 'package:app_asistencias/models/activity_model.dart';

class GetActivity {
  /// Últimas 20 actividades locales, ordenadas de más antigua -> más nueva
  static Future<List<ActivityModel>> getLocalData() async {
    final isar = await Database.instance();

    final recent =
        await isar.activityModels.where().sortByTimestamp().findAll();

    return recent.reversed.toList();
  }

  /// Últimas 20 actividades locales por asignación (serverId), ordenadas de más antigua -> más nueva
  static Future<List<ActivityModel>> getActivityByAssignment(
      int serverId) async {
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

static List<ActivityModel> dedupeActivities(List<ActivityModel> list) {
  final Map<String, ActivityModel> byKey = {};

  for (final a in list) {
    final key = a.dedupKey;

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
        a.timestamp.isAfter(existing.timestamp)) {
      byKey[key] = a;
    }
  }

  return byKey.values.toList();
}


  static Future<List<ActivityModel>> syncOnline() async {
    final online = await getOnlineData();

    final onlineRecent = online.where((a) => a.timestamp
        .isAfter(DateTime.now().subtract(const Duration(hours: 24)))).toList();

    final pendingSync = await getPendingSync();

     onlineRecent.addAll(pendingSync);

     final deduped = dedupeActivities(onlineRecent);
     deduped.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    
    final Map<int, List<ActivityModel>> RecentByService = {};
    for (final _activity in deduped) {
      final sid = _activity.serverId!;
      (RecentByService[sid] ??= []).add(_activity);
    }
    
    

    print('--- ONLINE RECENT BY SERVICE (24h) ---');
    RecentByService.forEach((sid, activities) {
      print('Servicio $sid → ${activities.length} actividades');

      for (final a in activities) {
        print(
          '  • ${a.timestamp} | motive=${a.motive} | status=${a.isSynced} ', 
        );
      }
    });


    return [];
  }

  static Future<List<ActivityModel>> syncOnlineToLocal() async {
    try {
      final online = await getOnlineData();
      if (online.isEmpty) return await getLocalData();

      final isar = await Database.instance();

      await isar.writeTxn(() async {
        for (final activity in online) {
          if (activity.timestamp == null) continue;

          // ESTRATEGIA: Buscar por VENTANA DE TIEMPO primero, no por ID.
          // Esto es más robusto si el ServerID o Motive difieren ligeramente (case sensitive, nulls, etc).
          final windowStart =
              activity.timestamp!.subtract(const Duration(hours: 6));
          final windowEnd = activity.timestamp!.add(const Duration(hours: 6));

          final candidates = await isar.activityModels
              .filter()
              .timestampBetween(windowStart, windowEnd)
              .findAll();

          ActivityModel? match;

          // Buscamos el mejor candidato dentro de los encontrados por fecha
          for (final c in candidates) {
            // Prioridad 1: Coincide DocumentID (si existe)
            if (c.documentId != null &&
                activity.documentId != null &&
                c.documentId == activity.documentId) {
              match = c;
              break;
            }

            // Prioridad 2: Coincide ServerID y Motive
            // Usamos OR para ser más laxos si ServerID falta en local
            bool sameServerId =
                (c.serverId != null && c.serverId == activity.serverId);
            bool sameMotive = (c.motive == activity.motive);

            if (sameServerId && sameMotive) {
              match = c;
              break;
            }

            // Prioridad 3: Solo coincide Motive y está muy cerca en el tiempo
            if (sameMotive) {
              // Si es el mismo motivo y está en la ventana de tiempo, asumimos que es el mismo
              // (Asumiendo que no haces 2 entradas en < 6 horas, que es lógico)
              match = c;
              break;
            }
          }

          // Si encontramos match, actualizamos el existente
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
