// ============================================================================
// KeyGroupService - Servicio para gestión de grupos de asistencias
// ============================================================================
// Este servicio proporciona funcionalidades avanzadas para trabajar con
// keyGroup, permitiendo agrupar, consultar y analizar asistencias de manera
// eficiente sin modificar la lógica existente del sistema.
// ============================================================================

import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/models/activity/activity_model.dart';
import 'package:app_asistencias/models/activity/motiveActivity_model.dart';
import 'package:app_asistencias/providers/history_provider.dart';
import 'package:isar/isar.dart';

/// Modelo que representa las estadísticas de un grupo de asistencias
class KeyGroupStats {
  final String keyGroup;
  final int totalEvents;
  final int entryCount;
  final int exitCount;
  final Duration? totalDuration;
  final bool isComplete; // tiene entrada y salida
  final bool hasPendingSync;
  final DateTime? firstEventTime;
  final DateTime? lastEventTime;

  const KeyGroupStats({
    required this.keyGroup,
    required this.totalEvents,
    required this.entryCount,
    required this.exitCount,
    this.totalDuration,
    required this.isComplete,
    required this.hasPendingSync,
    this.firstEventTime,
    this.lastEventTime,
  });

  /// Calcula el porcentaje de completitud del grupo
  double get completionPercentage {
    if (entryCount == 0) return 0.0;
    if (isComplete) return 100.0;
    return 50.0; // Solo tiene entrada
  }

  /// Indica si el grupo está activamente en curso
  bool get isActive => entryCount > 0 && exitCount == 0;
}

/// Resultado de búsqueda de grupos por rango de fechas
class KeyGroupDateRange {
  final DateTime startDate;
  final DateTime endDate;
  final List<ActivitySession> sessions;
  final int totalGroups;
  final Duration totalWorkedTime;

  const KeyGroupDateRange({
    required this.startDate,
    required this.endDate,
    required this.sessions,
    required this.totalGroups,
    required this.totalWorkedTime,
  });
}

/// Servicio principal para gestión de keyGroup
class KeyGroupService {
  /// Singleton instance
  static final KeyGroupService _instance = KeyGroupService._internal();
  factory KeyGroupService() => _instance;
  KeyGroupService._internal();

  /// Obtiene todas las actividades asociadas a un keyGroup específico
  Future<List<ActivityModel>> getActivitiesByKeyGroup(String keyGroup) async {
    final isar = await Database.instance();

    return await isar.activityModels
        .filter()
        .keyGroupEqualTo(keyGroup)
        .sortByTimestamp()
        .findAll();
  }

  /// Obtiene las estadísticas de un keyGroup específico
  Future<KeyGroupStats?> getKeyGroupStats(String keyGroup) async {
    final activities = await getActivitiesByKeyGroup(keyGroup);

    if (activities.isEmpty) return null;

    int entryCount = 0;
    int exitCount = 0;
    bool hasPending = false;
    DateTime? firstTime;
    DateTime? lastTime;

    for (final activity in activities) {
      final ts = activity.timestamp;

      if (ts != null) {
        if (firstTime == null || ts.isBefore(firstTime)) {
          firstTime = ts;
        }
        if (lastTime == null || ts.isAfter(lastTime)) {
          lastTime = ts;
        }
      }

      if (activity.motiveActivity == MotiveActivity.startWork) {
        entryCount++;
      } else if (activity.motiveActivity == MotiveActivity.endWork) {
        exitCount++;
      }

      if (!activity.isSynced) {
        hasPending = true;
      }
    }

    Duration? duration;
    if (firstTime != null && lastTime != null && exitCount > 0) {
      duration = lastTime.difference(firstTime);
    }

    return KeyGroupStats(
      keyGroup: keyGroup,
      totalEvents: activities.length,
      entryCount: entryCount,
      exitCount: exitCount,
      totalDuration: duration,
      isComplete: entryCount > 0 && exitCount > 0,
      hasPendingSync: hasPending,
      firstEventTime: firstTime,
      lastEventTime: lastTime,
    );
  }

  /// Obtiene los keyGroups únicos de las actividades locales
  Future<List<String>> getUniqueKeyGroups() async {
    final isar = await Database.instance();

    final activities = await isar.activityModels
        .filter()
        .keyGroupIsNotNull()
        .keyGroupIsNotEmpty()
        .findAll();

    final uniqueKeys = <String>{};
    for (final activity in activities) {
      if (activity.keyGroup != null && activity.keyGroup!.isNotEmpty) {
        uniqueKeys.add(activity.keyGroup!);
      }
    }

    return uniqueKeys.toList();
  }

  /// Obtiene todas las sesiones dentro de un rango de fechas
  Future<KeyGroupDateRange> getSessionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final isar = await Database.instance();

    // Normalizar fechas al inicio y fin del día
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    final activities = await isar.activityModels
        .filter()
        .timestampBetween(start, end)
        .keyGroupIsNotNull()
        .keyGroupIsNotEmpty()
        .sortByTimestamp()
        .findAll();

    // Usar la función existente para agrupar
    final sessions = groupByKeyGroup(activities);

    // Calcular tiempo total trabajado
    Duration totalWorked = Duration.zero;
    for (final session in sessions) {
      if (session.exitTimestamp != null) {
        totalWorked +=
            session.exitTimestamp!.difference(session.entryTimestamp);
      }
    }

    return KeyGroupDateRange(
      startDate: start,
      endDate: end,
      sessions: sessions,
      totalGroups: sessions.length,
      totalWorkedTime: totalWorked,
    );
  }

  /// Obtiene sesiones de un día específico
  Future<List<ActivitySession>> getSessionsByDay(DateTime date) async {
    final result = await getSessionsByDateRange(
      startDate: date,
      endDate: date,
    );
    return result.sessions;
  }

  /// Obtiene sesiones de la semana actual
  Future<KeyGroupDateRange> getCurrentWeekSessions() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return getSessionsByDateRange(startDate: weekStart, endDate: weekEnd);
  }

  /// Obtiene sesiones del mes actual
  Future<KeyGroupDateRange> getCurrentMonthSessions() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    return getSessionsByDateRange(startDate: monthStart, endDate: monthEnd);
  }

  /// Obtiene las sesiones activas (sin cerrar)
  Future<List<ActivitySession>> getActiveSessions() async {
    final isar = await Database.instance();

    final activities = await isar.activityModels
        .filter()
        .keyGroupIsNotNull()
        .keyGroupIsNotEmpty()
        .sortByTimestamp()
        .findAll();

    final sessions = groupByKeyGroup(activities);

    // Filtrar solo las que no tienen salida
    return sessions.where((s) => s.exitTimestamp == null).toList();
  }

  /// Verifica si un keyGroup específico está activo (sin cerrar)
  Future<bool> isKeyGroupActive(String keyGroup) async {
    final stats = await getKeyGroupStats(keyGroup);
    if (stats == null) return false;
    return stats.isActive;
  }

  /// Obtiene un resumen diario de grupos
  Future<Map<DateTime, List<ActivitySession>>> getDailyGroupsSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await getSessionsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );

    final Map<DateTime, List<ActivitySession>> dailyMap = {};

    for (final session in result.sessions) {
      final date = DateTime(
        session.entryTimestamp.year,
        session.entryTimestamp.month,
        session.entryTimestamp.day,
      );

      dailyMap.putIfAbsent(date, () => []).add(session);
    }

    return dailyMap;
  }

  /// Cuenta el número de sesiones pendientes de sincronización
  Future<int> getPendingSyncCount() async {
    final isar = await Database.instance();

    return await isar.activityModels
        .filter()
        .isSyncedEqualTo(false)
        .keyGroupIsNotNull()
        .keyGroupIsNotEmpty()
        .count();
  }

  /// Obtiene la sesión más reciente
  Future<ActivitySession?> getMostRecentSession() async {
    final isar = await Database.instance();

    final activities = await isar.activityModels
        .filter()
        .keyGroupIsNotNull()
        .keyGroupIsNotEmpty()
        .sortByTimestampDesc()
        .limit(50) // Limitamos para eficiencia
        .findAll();

    if (activities.isEmpty) return null;

    final sessions = groupByKeyGroup(activities);
    return sessions.isNotEmpty ? sessions.first : null;
  }
}
