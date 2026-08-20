import 'package:app_asistencias/models/overtime_request_model.dart';

/// Formato de fechas, horas y antigüedad para la feature de horas extra.
class OvertimeFormat {
  static const List<String> _weekdays = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

  static const List<String> _months = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Oct',
    'Nov',
    'Dic',
  ];

  /// "Jue 20 Ago 2026"
  static String fullDate(DateTime d) =>
      '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]} ${d.year}';

  /// "Jue 20 Ago"
  static String shortDate(DateTime d) =>
      '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';

  /// "20 Ago"
  static String dayMonth(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  /// "6:00 p.m." a partir de un DateTime.
  static String timeOf(DateTime d) => time(d.hour * 60 + d.minute);

  /// "6:00 p.m." a partir de los minutos desde medianoche.
  static String time(int minutesOfDay) {
    final normalized = minutesOfDay % (24 * 60);
    final hour24 = normalized ~/ 60;
    final minute = normalized % 60;

    final suffix = hour24 < 12 ? 'a.m.' : 'p.m.';
    var hour12 = hour24 % 12;
    if (hour12 == 0) hour12 = 12;

    return '$hour12:${minute.toString().padLeft(2, '0')} $suffix';
  }

  /// "Jue 20 Ago", o "Jue 20 Ago → Vie 21 Ago" si cruza a otro día.
  static String dateRange(OvertimeRequestModel r) {
    if (!r.spansDays) return shortDate(r.start);
    return '${shortDate(r.start)} → ${shortDate(r.end)}';
  }

  /// "6:00 p.m. – 10:00 p.m.", o "6:00 p.m. – 2:00 a.m. del 21 Ago" si cruza
  /// a otro día.
  static String timeRange(OvertimeRequestModel r) {
    if (!r.spansDays) {
      return '${timeOf(r.start)} – ${timeOf(r.end)}';
    }
    return '${timeOf(r.start)} – ${timeOf(r.end)} del ${dayMonth(r.end)}';
  }

  /// "4 h" / "19 h 24 min" / "45 min".
  static String duration(Duration d) {
    final total = d.inMinutes;
    if (total <= 0) return '0 min';

    final hours = total ~/ 60;
    final minutes = total % 60;

    if (hours == 0) return '$minutes min';
    if (minutes == 0) return '$hours h';
    return '$hours h $minutes min';
  }

  /// "4 horas extra" / "19 h 24 min extra" / "45 minutos extra".
  static String durationLong(Duration d) {
    final total = d.inMinutes;
    if (total <= 0) return 'Sin horas';

    final hours = total ~/ 60;
    final minutes = total % 60;

    if (minutes == 0) {
      return '$hours ${hours == 1 ? 'hora' : 'horas'} extra';
    }
    if (hours == 0) {
      return '$minutes ${minutes == 1 ? 'minuto' : 'minutos'} extra';
    }
    return '$hours h $minutes min extra';
  }

  /// "recién enviado" / "enviado hace 5 h" / "enviado hace 3d". Devuelve
  /// vacío cuando la solicitud vino del servidor, que no guarda el envío.
  static String submittedAgo(DateTime? submittedAt, {DateTime? now}) {
    if (submittedAt == null) return '';

    final reference = now ?? DateTime.now();
    final diff = reference.difference(submittedAt);

    if (diff.isNegative || diff.inMinutes < 60) return 'recién enviado';
    if (diff.inHours < 24) return 'enviado hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'enviado hace ${diff.inDays}d';

    final weeks = diff.inDays ~/ 7;
    if (weeks < 5) return 'enviado hace $weeks sem';

    final months = diff.inDays ~/ 30;
    return 'enviado hace $months mes${months == 1 ? '' : 'es'}';
  }
}
