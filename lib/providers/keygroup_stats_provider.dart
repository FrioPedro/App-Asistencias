// ============================================================================
// KeyGroupStatsProvider - Proveedor de estadísticas de grupos
// ============================================================================
// Un proveedor que expone estadísticas agregadas de las sesiones agrupadas
// por keyGroup, útil para dashboards y reportes.
// ============================================================================

import 'package:app_asistencias/domain/keygroup/keygroup_service.dart';
import 'package:app_asistencias/domain/keygroup/keygroup_extensions.dart';
import 'package:app_asistencias/providers/history_provider.dart';

/// Modelo para estadísticas generales del día
class DailyStats {
  final DateTime date;
  final int totalSessions;
  final int completedSessions;
  final int ongoingSessions;
  final int pendingSyncSessions;
  final Duration totalWorkedTime;
  final Duration averageSessionDuration;

  const DailyStats({
    required this.date,
    required this.totalSessions,
    required this.completedSessions,
    required this.ongoingSessions,
    required this.pendingSyncSessions,
    required this.totalWorkedTime,
    required this.averageSessionDuration,
  });

  /// Formatea el tiempo total trabajado
  String get formattedTotalTime {
    final hours = totalWorkedTime.inHours;
    final minutes = totalWorkedTime.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  /// Formatea la duración promedio
  String get formattedAverageTime {
    final hours = averageSessionDuration.inHours;
    final minutes = averageSessionDuration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Porcentaje de sesiones completadas
  double get completionRate {
    if (totalSessions == 0) return 0.0;
    return (completedSessions / totalSessions) * 100;
  }
}

/// Modelo para estadísticas semanales
class WeeklyStats {
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<DailyStats> dailyBreakdown;
  final int totalSessions;
  final Duration totalWorkedTime;
  final Map<int, int> sessionsByWeekday;

  const WeeklyStats({
    required this.weekStart,
    required this.weekEnd,
    required this.dailyBreakdown,
    required this.totalSessions,
    required this.totalWorkedTime,
    required this.sessionsByWeekday,
  });

  /// Formatea el tiempo total de la semana
  String get formattedTotalTime {
    final hours = totalWorkedTime.inHours;
    final minutes = totalWorkedTime.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  /// Día con más actividad
  String get busiestDayName {
    if (sessionsByWeekday.isEmpty) return 'N/A';

    final maxEntry =
        sessionsByWeekday.entries.reduce((a, b) => a.value > b.value ? a : b);

    const dayNames = {
      1: 'Lunes',
      2: 'Martes',
      3: 'Miércoles',
      4: 'Jueves',
      5: 'Viernes',
      6: 'Sábado',
      7: 'Domingo',
    };

    return dayNames[maxEntry.key] ?? 'N/A';
  }
}

/// Proveedor principal de estadísticas
class KeyGroupStatsProvider {
  final KeyGroupService _service = KeyGroupService();

  /// Obtiene las estadísticas del día actual
  Future<DailyStats> getTodayStats() async {
    final today = DateTime.now();
    return getDailyStats(today);
  }

  /// Obtiene las estadísticas de un día específico
  Future<DailyStats> getDailyStats(DateTime date) async {
    final sessions = await _service.getSessionsByDay(date);

    final completed = sessions.completedSessions;
    final ongoing = sessions.ongoingSessions;
    final pendingSync = sessions.pendingSyncSessions;
    final totalWorked = sessions.totalWorkedTime;

    Duration avgDuration = Duration.zero;
    if (completed.isNotEmpty) {
      avgDuration = Duration(
        milliseconds: totalWorked.inMilliseconds ~/ completed.length,
      );
    }

    return DailyStats(
      date: date,
      totalSessions: sessions.length,
      completedSessions: completed.length,
      ongoingSessions: ongoing.length,
      pendingSyncSessions: pendingSync.length,
      totalWorkedTime: totalWorked,
      averageSessionDuration: avgDuration,
    );
  }

  /// Obtiene estadísticas de los últimos N días
  Future<List<DailyStats>> getLastNDaysStats(int days) async {
    final List<DailyStats> stats = [];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dailyStats = await getDailyStats(date);
      stats.add(dailyStats);
    }

    return stats;
  }

  /// Obtiene estadísticas de la semana actual
  Future<WeeklyStats> getCurrentWeekStats() async {
    final result = await _service.getCurrentWeekSessions();

    // Obtener breakdown diario
    final dailyBreakdown = <DailyStats>[];
    final dailyMap = result.sessions.groupedByDay;

    for (final entry in dailyMap.entries) {
      final daySessions = entry.value;
      final completed = daySessions.completedSessions;
      final ongoing = daySessions.ongoingSessions;
      final pendingSync = daySessions.pendingSyncSessions;
      final totalWorked = daySessions.totalWorkedTime;

      Duration avgDuration = Duration.zero;
      if (completed.isNotEmpty) {
        avgDuration = Duration(
          milliseconds: totalWorked.inMilliseconds ~/ completed.length,
        );
      }

      dailyBreakdown.add(DailyStats(
        date: entry.key,
        totalSessions: daySessions.length,
        completedSessions: completed.length,
        ongoingSessions: ongoing.length,
        pendingSyncSessions: pendingSync.length,
        totalWorkedTime: totalWorked,
        averageSessionDuration: avgDuration,
      ));
    }

    // Ordenar por fecha
    dailyBreakdown.sort((a, b) => a.date.compareTo(b.date));

    return WeeklyStats(
      weekStart: result.startDate,
      weekEnd: result.endDate,
      dailyBreakdown: dailyBreakdown,
      totalSessions: result.totalGroups,
      totalWorkedTime: result.totalWorkedTime,
      sessionsByWeekday: result.sessions.countByWeekday,
    );
  }

  /// Obtiene el resumen rápido para UI
  Future<Map<String, dynamic>> getQuickSummary() async {
    final todayStats = await getTodayStats();
    final weekStats = await getCurrentWeekStats();
    final pendingCount = await _service.getPendingSyncCount();
    final activeSessions = await _service.getActiveSessions();

    return {
      'todaySessions': todayStats.totalSessions,
      'todayWorkedTime': todayStats.formattedTotalTime,
      'todayCompleted': todayStats.completedSessions,
      'todayOngoing': todayStats.ongoingSessions,
      'weekSessions': weekStats.totalSessions,
      'weekWorkedTime': weekStats.formattedTotalTime,
      'pendingSync': pendingCount,
      'activeSessions': activeSessions.length,
      'busiestDay': weekStats.busiestDayName,
    };
  }

  /// Obtiene las sesiones activas actuales
  Future<List<ActivitySession>> getActiveSessions() {
    return _service.getActiveSessions();
  }

  /// Obtiene la sesión más reciente
  Future<ActivitySession?> getMostRecentSession() {
    return _service.getMostRecentSession();
  }
}
