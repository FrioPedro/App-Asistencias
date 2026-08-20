import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/models/note_model.dart' show SyncStatus;
import 'package:app_asistencias/models/overtime_request_model.dart';

class CreateOvertimeRequest {
  /// Guarda la solicitud localmente como `pending`.
  static Future<OvertimeRequestModel> createAndStore({
    required int projectId,
    required DateTime start,
    required DateTime end,
    required String justification,
  }) async {
    final request = OvertimeRequestModel.create(
      projectId: projectId,
      start: start,
      end: end,
      justification: justification.trim(),
      syncStatus: SyncStatus.pending,
    );

    final isar = await Database.instance();
    await isar.writeTxn(() async {
      await isar.overtimeRequestModels.put(request);
    });

    return request;
  }
}
