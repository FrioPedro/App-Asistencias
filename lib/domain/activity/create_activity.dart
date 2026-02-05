import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/models/activity_model.dart';
import 'package:app_asistencias/models/assigment_model.dart';
import 'package:app_asistencias/models/taskType_model.dart';
import 'package:app_asistencias/models/user_zone.dart';
import 'package:app_asistencias/models/motiveActivity_model.dart';
import 'get_activity.dart';

class CreateActivity {
  /// Iniciar una SESIÓN (Entrada)
  /// Crea una nueva fila en DB con Token autogenerado y datos de entrada.
  static Future<ActivityModel> storeEntry({
    required AssigmentModel assignment,
    required TaskType task,
    required String collaboratorDocumentId,
    required UserZone userZone,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  }) async {
    final isar = await Database.instance();

    final activity = ActivityModel(
      assigmentId: assignment.serverId,
      documentId: assignment.documentId,
      client: assignment.client,
      description: assignment.description,
      collaboratordocumentId: collaboratorDocumentId,
      zone: userZone,
      task: task,
      activityType: assignment.assigmentType,
      motiveActivity: MotiveActivity.startWork,
      timestamp:timestamp,
      latitude:latitude,
      longitude:longitude,
      isSynced: false,
    );

    await isar.writeTxn(() async {
      await isar.activityModels.put(activity);
    });

    return activity;
  }

  /// Cerrar una SESIÓN (Salida)
  static Future<ActivityModel?> storeExit({
    required int serverId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  }) async {
    final isar = await Database.instance();

    // 1. Obtener sesión activa (la que tiene exitTimestamp == null)
    final active = await GetActivity.getActive(serverId);
    if (active == null) {
      print(
          "Error: Intentando cerrar sesión para ServerID $serverId pero no hay ninguna abierta.");
      return null;
    }

    // 2. Actualizar campos de salida
    active.exitTimestamp = timestamp ?? DateTime.now();
    active.exitLatitude = latitude;
    active.exitLongitude = longitude;
    active.isSynced = false; // Marcar para subir actualización

    await isar.writeTxn(() async {
      await isar.activityModels.put(active);
    });

    return active;
  }
}
