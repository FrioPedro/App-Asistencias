import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/models/assigment_model.dart';
import 'package:app_asistencias/domain/overtime/create_overtime_request.dart';
import 'package:app_asistencias/domain/overtime/sync_overtime_request.dart';
import 'package:app_asistencias/models/overtime_request_model.dart';
import 'package:isar/isar.dart';

class OvertimeProvider {
  final OvertimeSyncService _sync = OvertimeSyncService();

  /// Crea la solicitud local (pending) e intenta sincronizar.
  Future<OvertimeRequestModel> createRequest({
    required int projectId,
    required DateTime start,
    required DateTime end,
    required String justification,
  }) async {
    final request = await CreateOvertimeRequest.createAndStore(
      projectId: projectId,
      start: start,
      end: end,
      justification: justification,
    );

    // La solicitud ya esta guardada como pending: el envio corre suelto y un
    // fallo lo reintenta el worker, asi que no debe abortar la creacion.
    _sync.syncIfPossible().catchError((_) {});

    return request;
  }

  /// Solicitudes agrupadas para la pantalla de consulta. Las que ya
  /// empezaron caen en `pasadas` sin importar su estado; el resto se separa
  /// por estado. Vigentes ordenadas por la que empieza antes, pasadas de la
  /// mas reciente a la mas antigua.
  Future<OvertimeRequestGroups> fetchLocalRequests({
    int limit = 200,
  }) async {
    final isar = await Database.instance();

    final all = await isar.overtimeRequestModels
        .where()
        .sortByStartDesc()
        .limit(limit)
        .findAll();

    final now = DateTime.now();

    final pasadas = all.where((r) => r.start.isBefore(now)).toList()
      ..sort((a, b) => b.start.compareTo(a.start));

    final vigentes = all.where((r) => !r.start.isBefore(now)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    List<OvertimeRequestModel> byStatus(OvertimeStatus status) =>
        vigentes.where((r) => r.status == status).toList();

    final assigments = await _assigmentsFor(all);

    return OvertimeRequestGroups(
      projectNames: _projectNames(assigments),
      projectCodes: _projectCodes(assigments),
      approved: byStatus(OvertimeStatus.approved),
      pending: byStatus(OvertimeStatus.pending),
      rejected: byStatus(OvertimeStatus.rejected),
      pasadas: pasadas,
    );
  }

  /// El listado de horas extra solo devuelve el identificador de proyecto; el
  /// nombre y el codigo viven en la asignacion.
  Future<List<AssigmentModel>> _assigmentsFor(
    List<OvertimeRequestModel> requests,
  ) async {
    if (requests.isEmpty) return const [];

    final isar = await Database.instance();
    final ids = requests.map((r) => r.projectId).toSet();

    return isar.assigmentModels
        .filter()
        .anyOf(ids, (q, id) => q.serverIdEqualTo(id))
        .findAll();
  }

  Map<int, String> _projectNames(List<AssigmentModel> assigments) => {
        for (final a in assigments)
          if (a.description?.isNotEmpty ?? false)
            a.serverId: a.description!
          else if (a.documentId?.isNotEmpty ?? false)
            a.serverId: a.documentId!,
      };

  /// `documentId` es el campo `Document` del servidor: "PRS 2026-13".
  Map<int, String> _projectCodes(List<AssigmentModel> assigments) => {
        for (final a in assigments)
          if (a.documentId?.isNotEmpty ?? false) a.serverId: a.documentId!,
      };

  /// Conteo para el badge del header: solo lo que el supervisor todavia
  /// puede resolver. Las que ya pasaron dejan de contar, y un fallo de subida
  /// no cuenta porque se reintenta solo.
  Future<int> countPending() async {
    final isar = await Database.instance();

    return isar.overtimeRequestModels
        .filter()
        .statusEqualTo(OvertimeStatus.pending)
        .startGreaterThan(DateTime.now())
        .count();
  }

  /// Aprobadas que todavia no pasaron: son las que el operario necesita ver.
  Future<int> countApproved() async {
    final isar = await Database.instance();

    return isar.overtimeRequestModels
        .filter()
        .statusEqualTo(OvertimeStatus.approved)
        .startGreaterThan(DateTime.now())
        .count();
  }

  /// Refresco manual.
  Future<void> syncNow() => _sync.syncIfPossible();
}

/// Resultado de [OvertimeProvider.fetchLocalRequests]: una lista por seccion
/// de la pantalla de consulta.
class OvertimeRequestGroups {
  /// Nombre de proyecto por `OvertimeRequestModel.projectId`.
  final Map<int, String> projectNames;

  /// Codigo de proyecto por `OvertimeRequestModel.projectId`.
  final Map<int, String> projectCodes;

  final List<OvertimeRequestModel> approved;
  final List<OvertimeRequestModel> pending;
  final List<OvertimeRequestModel> rejected;
  final List<OvertimeRequestModel> pasadas;

  const OvertimeRequestGroups({
    this.projectNames = const {},
    this.projectCodes = const {},
    this.approved = const [],
    this.pending = const [],
    this.rejected = const [],
    this.pasadas = const [],
  });

  /// Si la asignacion no bajo a local, queda el identificador a la vista.
  String projectName(OvertimeRequestModel request) =>
      projectNames[request.projectId] ?? 'Proyecto #${request.projectId}';

  /// Vacio cuando la asignacion no bajo a local: la tarjeta omite el codigo en
  /// vez de mostrar un placeholder.
  String projectCode(OvertimeRequestModel request) =>
      projectCodes[request.projectId] ?? '';

  bool get isEmpty =>
      approved.isEmpty &&
      pending.isEmpty &&
      rejected.isEmpty &&
      pasadas.isEmpty;
}
