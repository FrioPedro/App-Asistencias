import 'package:app_asistencias/core/database.dart';
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

    await _sync.syncIfPossible();

    return request;
  }

  /// Solicitudes para la pantalla de consulta: pendientes primero (la que
  /// empieza antes arriba), luego las resueltas de la mas reciente a la mas
  /// antigua. Las traidas del servidor no tienen fecha de envio, por eso el
  /// orden es por fecha de inicio.
  Future<List<OvertimeRequestModel>> fetchLocalRequests({
    int limit = 200,
  }) async {
    final isar = await Database.instance();

    final all = await isar.overtimeRequestModels
        .where()
        .sortByStartDesc()
        .limit(limit)
        .findAll();

    final pending = all
        .where((r) => r.status == OvertimeStatus.pending)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final resolved =
        all.where((r) => r.status != OvertimeStatus.pending).toList();

    return [...pending, ...resolved];
  }

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
