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

  /// "20"
  static String day(DateTime d) => '${d.day}';

  /// "20 Ago"
  static String dayMonth(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  /// "20 Ago 27"
  static String dayMonthYear(DateTime d) => '${d.day} ${_months[d.month - 1]} '
      '${(d.year % 100).toString().padLeft(2, '0')}';

  /// "por Juan Perez", o vacio: una solicitud pendiente todavia no tiene quien
  /// la resuelva.
  static String approverLine(OvertimeRequestModel r) {
    final approver = r.approver;

    if (r.status == OvertimeStatus.pending ||
        approver == null ||
        approver.isEmpty) {
      return '';
    }

    return 'por $approver';
  }

  /// "Pendiente" / "Aprobado" / "Rechazado".
  static String statusLabel(OvertimeStatus status) {
    switch (status) {
      case OvertimeStatus.approved:
        return 'Aprobado';
      case OvertimeStatus.rejected:
        return 'Rechazado';
      case OvertimeStatus.pending:
        return 'Pendiente';
    }
  }

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

  /// "20 Ago", "20 Ago → 21 Ago", o "31 Dic 26 → 1 Ene 27" cuando el
  /// rango cruza de año.
  static String dateRange(OvertimeRequestModel r) {
    if (!r.spansDays) return dayMonth(r.start);
    if (r.start.year != r.end.year) {
      return '${dayMonthYear(r.start)} → ${dayMonthYear(r.end)}';
    } else if (r.start.month == r.end.month) {
      return '${day(r.start)} → ${dayMonth(r.end)}';
    }
    return '${dayMonth(r.start)} → ${dayMonth(r.end)}';
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

  /// "20 Ago 27, 6:00 p.m.". Vacio cuando la solicitud vino del servidor, que
  /// no devuelve el envio.
  static String submittedOn(DateTime? submittedAt) {
    if (submittedAt == null) return '';

    return '${dayMonthYear(submittedAt)}, ${timeOf(submittedAt)}';
  }

  /// "recién" / "5 h" / "3d". Devuelve
  /// vacío cuando la solicitud vino del servidor, que no guarda el envío.
  static String submittedAgo(DateTime? submittedAt, {DateTime? now}) {
    if (submittedAt == null) return '';

    final reference = now ?? DateTime.now();
    final diff = reference.difference(submittedAt);

    if (diff.isNegative || diff.inMinutes < 60) return 'recién';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'hace ${diff.inDays}d';

    final weeks = diff.inDays ~/ 7;
    if (weeks < 5) return 'hace $weeks sem';

    final months = diff.inDays ~/ 30;
    return 'hace $months mes${months == 1 ? '' : 'es'}';
  }
}
