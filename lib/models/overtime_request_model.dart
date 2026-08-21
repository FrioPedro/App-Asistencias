import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';

import 'package:app_asistencias/models/note_model.dart' show SyncStatus;

part 'overtime_request_model.g.dart';

/// Estado de la solicitud desde el punto de vista del operario.
enum OvertimeStatus { pending, approved, rejected }

/// Solicitud anticipada de horas extra.
///
/// El servidor maneja el bloque como dos timestamps (`Initial` / `Finish`),
/// asi que aca se guardan igual. La sincronizacion vive en
/// `lib/domain/overtime/sync_overtime_request.dart`.
@collection
class OvertimeRequestModel {
  Id id = Isar.autoIncrement;

  /// Identifier de la asignacion (`AssigmentModel.serverId`). Es el `project`
  /// que piden los dos endpoints.
  @Index()
  late int projectId;

  /// Inicio del bloque, fecha y hora juntas.
  late DateTime start;

  /// Fin del bloque, fecha y hora juntas.
  late DateTime end;

  /// Viaja al servidor como `description`.
  late String justification;

  /// Cuando se envio la solicitud. Lo sella la app al crearla y lo confirma
  /// el servidor al listar. Queda en null si ninguno de los dos lo aporta.
  @Index()
  DateTime? submittedAt;

  /// Nombre del colaborador, tal como lo devuelve el listado.
  String? collaborator;

  /// Quien aprobo o rechazo la solicitud (`Approver`). Vacio mientras esta
  /// pendiente.
  String? approver;

  /// Respuesta del supervisor (`Sustenance`).
  String? sustenance;

  /// Cuando el supervisor resolvio la solicitud. Null mientras sigue
  /// pendiente.
  DateTime? resolvedAt;

  /// Inicio que se habia solicitado antes de que el supervisor lo moviera
  /// (`InitialChanged`). Null cuando nadie lo toco: `start` siempre es el
  /// valor vigente.
  DateTime? previousStart;

  /// Igual que [previousStart], para el fin (`FinishChanged`).
  DateTime? previousEnd;

  @enumerated
  OvertimeStatus status = OvertimeStatus.pending;

  @Index()
  @enumerated
  SyncStatus syncStatus = SyncStatus.pending;

  @Index(unique: true, replace: true)
  late String dedupKey;

  /// Constructor que usa Isar al leer de la base.
  OvertimeRequestModel({
    required this.projectId,
    required this.start,
    required this.end,
    required this.justification,
    this.submittedAt,
    this.collaborator,
    this.approver,
    this.sustenance,
    this.resolvedAt,
    this.previousStart,
    this.previousEnd,
    this.status = OvertimeStatus.pending,
    this.syncStatus = SyncStatus.pending,
  }) {
    dedupKey = buildDedupKey(projectId: projectId, start: start, end: end);
  }

  /// Constructor de la app: descarta los segundos y sella la fecha de envio.
  factory OvertimeRequestModel.create({
    required int projectId,
    required DateTime start,
    required DateTime end,
    required String justification,
    DateTime? submittedAt,
    OvertimeStatus status = OvertimeStatus.pending,
    SyncStatus syncStatus = SyncStatus.pending,
  }) {
    return OvertimeRequestModel(
      projectId: projectId,
      start: toMinute(start),
      end: toMinute(end),
      justification: justification,
      submittedAt: submittedAt ?? DateTime.now(),
      status: status,
      syncStatus: syncStatus,
    );
  }

  /// El listado no devuelve el proyecto: lo aporta quien hizo la consulta.
  OvertimeRequestModel.fromServer(
    Map<String, dynamic> json, {
    required int projectId,
  }) {
    this.projectId = projectId;
    start = toMinute(_parseDate(json['Initial']));
    end = toMinute(_parseDate(json['Finish']));
    justification = (json['Description'] as String?) ?? '';
    collaborator = json['Collaborator'] as String?;
    approver = _parseText(json['Approver']);
    sustenance = _parseText(json['Sustenance']);
    resolvedAt = _parseResolvedAt(json);
    previousStart = _changedFrom(json['InitialChanged'], start);
    previousEnd = _changedFrom(json['FinishChanged'], end);
    submittedAt = _parseNullableDate(json['Timestamp']);
    status = _parseStatus(json['Status']);

    syncStatus = SyncStatus.synced;

    dedupKey = buildDedupKey(projectId: projectId, start: start, end: end);
  }

  // ---------------- calculo de horas ----------------

  @ignore
  Duration get duration => end.difference(start);

  /// El fin cae en un dia distinto al del inicio.
  @ignore
  bool get spansDays => dateOnly(end).isAfter(dateOnly(start));

  // ---------------- helpers ----------------

  /// Normaliza a medianoche local.
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Descarta segundos y milisegundos: el servidor trabaja al minuto.
  static DateTime toMinute(DateTime d) =>
      DateTime(d.year, d.month, d.day, d.hour, d.minute);

  /// `Approved` sella la aprobacion y tambien el rechazo; `Modified` sella el
  /// cambio de horas, que equivale a una re-aprobacion. Gana la mas reciente:
  /// esa es la ultima vez que el supervisor definio el bloque.
  static DateTime? _parseResolvedAt(Map<String, dynamic> json) {
    final dates = [json['Approved'], json['Modified']]
        .map(_parseNullableDate)
        .whereType<DateTime>()
        .toList();

    if (dates.isEmpty) return null;

    return dates.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// El listado manda `InitialChanged`/`FinishChanged` incluso cuando el
  /// supervisor no movio la hora: solo cuenta si difiere del vigente.
  static DateTime? _changedFrom(dynamic raw, DateTime current) {
    final previous = _parseNullableDate(raw);
    if (previous == null) return null;

    final normalized = toMinute(previous);
    return normalized.isAtSameMomentAs(current) ? null : normalized;
  }

  static String buildDedupKey({
    required int projectId,
    required DateTime start,
    required DateTime end,
  }) {
    final base = [
      projectId.toString(),
      toMinute(start).toIso8601String(),
      toMinute(end).toIso8601String(),
    ].join('|');

    return sha1.convert(utf8.encode(base)).toString().substring(0, 20);
  }

  /// Para los campos opcionales del listado: ausente, null o ilegible es null,
  /// no la fecha cero que devuelve [_parseDate].
  static DateTime? _parseNullableDate(dynamic v) {
    if (v == null) return null;

    final parsed = _parseDate(v);
    return parsed.millisecondsSinceEpoch == 0 ? null : toMinute(parsed);
  }

  /// El listado manda los textos vacios como `""`: se guardan como null para
  /// que la UI los trate igual que un campo ausente.
  static String? _parseText(dynamic v) {
    if (v is! String) return null;

    final trimmed = v.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static OvertimeStatus _parseStatus(dynamic v) {
    final raw = (v is String ? v : v?.toString() ?? '').trim().toLowerCase();
    switch (raw) {
      case 'aprobado':
        return OvertimeStatus.approved;
      case 'rechazado':
        return OvertimeStatus.rejected;
      default:
        return OvertimeStatus.pending;
    }
  }

  static DateTime _parseDate(dynamic v) {
    final fallback = DateTime.fromMillisecondsSinceEpoch(0);

    if (v == null) return fallback;
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);

    if (v is String) {
      final iso = DateTime.tryParse(v);
      if (iso != null) return iso;

      final fixed = DateTime.tryParse(v.replaceFirst(' ', 'T'));
      if (fixed != null) return fixed;
    }

    return fallback;
  }
}
