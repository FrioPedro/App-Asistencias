// ============================================================================
// KeyGroup Extensions - Extensiones de utilidad para ActivitySession
// ============================================================================
// Proporciona métodos de extensión para facilitar el trabajo con sesiones
// agrupadas por keyGroup, incluyendo formateo, validación y transformaciones.
// ============================================================================

import 'package:app_asistencias/providers/history_provider.dart';
import 'package:app_asistencias/models/taskType_model.dart';
import 'package:app_asistencias/models/assigment_model.dart';
import 'package:intl/intl.dart';

/// Extensiones para ActivitySession
extension ActivitySessionExtensions on ActivitySession {
  /// Calcula la duración de la sesión
  Duration? get duration {
    if (exitTimestamp == null) return null;
    return exitTimestamp!.difference(entryTimestamp);
  }

  /// Formatea la duración en formato legible (ej: "2h 30m")
  String get formattedDuration {
    final dur = duration;
    if (dur == null) return 'En curso';

    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Fecha formateada de entrada
  String get formattedEntryDate {
    return DateFormat('dd/MM/yyyy').format(entryTimestamp);
  }

  /// Hora formateada de entrada
  String get formattedEntryTime {
    return DateFormat('hh:mm a').format(entryTimestamp);
  }

  /// Hora formateada de salida
  String? get formattedExitTime {
    if (exitTimestamp == null) return null;
    return DateFormat('hh:mm a').format(exitTimestamp!);
  }

  /// Rango de tiempo formateado
  String get timeRange {
    final entry = formattedEntryTime;
    final exit = formattedExitTime ?? 'En curso';
    return '$entry - $exit';
  }

  /// Indica si la sesión está en curso
  bool get isOngoing => exitTimestamp == null;

  /// Indica si la sesión fue en el día actual
  bool get isToday {
    final now = DateTime.now();
    return entryTimestamp.year == now.year &&
        entryTimestamp.month == now.month &&
        entryTimestamp.day == now.day;
  }

  /// Indica si la sesión fue ayer
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return entryTimestamp.year == yesterday.year &&
        entryTimestamp.month == yesterday.month &&
        entryTimestamp.day == yesterday.day;
  }

  /// Descripción de fecha relativa (Hoy, Ayer, o fecha)
  String get relativeDateDescription {
    if (isToday) return 'Hoy';
    if (isYesterday) return 'Ayer';
    return formattedEntryDate;
  }

  /// Obtiene el identificador corto del keyGroup (primeros 8 caracteres)
  String get shortKeyGroup {
    if (keyGroup.length <= 8) return keyGroup;
    return keyGroup.substring(0, 8);
  }

  /// Indica si la sesión duró más de cierta cantidad de horas
  bool exceededHours(int hours) {
    final dur = duration;
    if (dur == null) return false;
    return dur.inHours >= hours;
  }

  /// Indica si la sesión es corta (menos de 30 minutos)
  bool get isShortSession {
    final dur = duration;
    if (dur == null) return false;
    return dur.inMinutes < 30;
  }

  /// Indica si la sesión es larga (más de 8 horas)
  bool get isLongSession => exceededHours(8);

  /// Resumen en texto de la sesión
  String get summary {
    final task = this.task.label;
    final time = formattedDuration;
    final date = relativeDateDescription;
    return '$task • $date • $time';
  }
}

/// Extensiones para listas de ActivitySession
extension ActivitySessionListExtensions on List<ActivitySession> {
  /// Calcula el tiempo total trabajado
  Duration get totalWorkedTime {
    Duration total = Duration.zero;
    for (final session in this) {
      final dur = session.duration;
      if (dur != null) {
        total += dur;
      }
    }
    return total;
  }

  /// Formatea el tiempo total trabajado
  String get formattedTotalWorkedTime {
    final dur = totalWorkedTime;
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  /// Filtra sesiones del día actual
  List<ActivitySession> get todaySessions {
    return where((s) => s.isToday).toList();
  }

  /// Filtra sesiones en curso
  List<ActivitySession> get ongoingSessions {
    return where((s) => s.isOngoing).toList();
  }

  /// Filtra sesiones completadas
  List<ActivitySession> get completedSessions {
    return where((s) => !s.isOngoing).toList();
  }

  /// Filtra sesiones pendientes de sincronización
  List<ActivitySession> get pendingSyncSessions {
    return where((s) => s.hasPendingSync).toList();
  }

  /// Agrupa sesiones por día
  Map<DateTime, List<ActivitySession>> get groupedByDay {
    final Map<DateTime, List<ActivitySession>> grouped = {};

    for (final session in this) {
      final date = DateTime(
        session.entryTimestamp.year,
        session.entryTimestamp.month,
        session.entryTimestamp.day,
      );
      grouped.putIfAbsent(date, () => []).add(session);
    }

    return grouped;
  }

  /// Agrupa sesiones por tipo de tarea
  Map<TaskType, List<ActivitySession>> get groupedByTaskType {
    final Map<TaskType, List<ActivitySession>> grouped = {};

    for (final session in this) {
      grouped.putIfAbsent(session.task, () => []).add(session);
    }

    return grouped;
  }

  /// Agrupa sesiones por tipo de asignación
  Map<AssigmentType, List<ActivitySession>> get groupedByAssignmentType {
    final Map<AssigmentType, List<ActivitySession>> grouped = {};

    for (final session in this) {
      grouped.putIfAbsent(session.activityType, () => []).add(session);
    }

    return grouped;
  }

  /// Obtiene la sesión más reciente
  ActivitySession? get mostRecent {
    if (isEmpty) return null;
    return reduce((a, b) {
      final aLast = a.exitTimestamp ?? a.entryTimestamp;
      final bLast = b.exitTimestamp ?? b.entryTimestamp;
      return aLast.isAfter(bLast) ? a : b;
    });
  }

  /// Obtiene la sesión más antigua
  ActivitySession? get oldest {
    if (isEmpty) return null;
    return reduce((a, b) {
      return a.entryTimestamp.isBefore(b.entryTimestamp) ? a : b;
    });
  }

  /// Cuenta sesiones por cada día de la semana
  Map<int, int> get countByWeekday {
    final Map<int, int> counts = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
      6: 0,
      7: 0,
    };

    for (final session in this) {
      final weekday = session.entryTimestamp.weekday;
      counts[weekday] = (counts[weekday] ?? 0) + 1;
    }

    return counts;
  }
}
