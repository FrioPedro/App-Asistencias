import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/models/activity/activity_model.dart';
import 'package:app_asistencias/models/assigment_model.dart';
import 'package:app_asistencias/models/taskType_model.dart';
import 'package:app_asistencias/models/user/user_zone.dart';
import 'package:app_asistencias/models/activity/motiveActivity_model.dart';
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
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      isSynced: false,
    );

    await isar.writeTxn(() async {
      await isar.activityModels.put(activity);
    });

    return activity;
  }

  /// Cerrar una SESIÓN (Salida)
  static Future<ActivityModel?> storeExit({
    required String keyGroup,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  }) async {
    final isar = await Database.instance();

    // 1) Obtener sesión activa por keyGroup
    final active = await GetActivity.getActive(keyGroup);
    if (active == null) {
      print(
        "Error: Intentando cerrar sesión para keyGroup $keyGroup pero no hay ninguna abierta.",
      );
      return null;
    }

    // 2) Actualizar el mismo registro (cerrar)
    /*
    active.motiveActivity = MotiveActivity.endWork;
    active.timestamp = timestamp ?? DateTime.now();
    active.latitude = latitude;
    active.longitude = longitude;
    active.isSynced = false;
    */
    final salida = active.copyWith(
      motiveActivity: MotiveActivity.endWork, // el que corresponda
      timestamp: timestamp ?? DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      isSynced: false,
      keyGroup: active.keyGroup, // opcional: para que se regenere
    );
    print("[FLAG DE BORRADO]");
    print(salida.id);
    await isar.writeTxn(() async {
      await isar.activityModels.put(salida);
    });

    return active;
  }
}
