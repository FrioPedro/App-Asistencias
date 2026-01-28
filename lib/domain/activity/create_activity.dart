
import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/models/activity_model.dart';
import 'package:app_asistencias/models/assigment_model.dart';

import 'get_activity.dart';

class CreateActivity {
  /// Guarda una marcación "pura" (sin inventar registros, sin modificar descripción).
  static Future<ActivityModel> storeActivity({
    required AssigmentModel assignment,
    required TaskType task,
    required MotiveType motive,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? description,
  }) async {
    final isar = await Database.instance();

    final activity = ActivityModel(
      serverId: assignment.serverId,
      documentId: assignment.documentId,
      client: assignment.client,
      description: description ?? assignment.description,
      collaborator: null,
      motiveText: motive.label, // opcional (puedes poner null si no lo usas)
      motive: motive,
      task: task,
      activityType: assignment.assigmentType,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp ?? DateTime.now(),
      isSynced: false,
    );

    await isar.writeTxn(() async {
      await isar.activityModels.put(activity);
    });

    return activity;
  }

  /// Entrada pura
  static Future<ActivityModel> storeEntry({
    required AssigmentModel assignment,
    required TaskType task,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  }) {
    return storeActivity(
      assignment: assignment,
      task: task,
      motive: MotiveType.entry,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
    );
  }

  /// Salida pura:
  /// - NO crea registros extras
  /// - NO modifica nada
  /// - Solo valida que exista un "activo" (último motive = entry) y crea 1 salida.
  static Future<ActivityModel?> storeExit({
    required int serverId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  }) async {
    final isar = await Database.instance();

    final active = await GetActivity.getActive(serverId);
    if (active == null) return null;

    final activity = ActivityModel(
      serverId: active.serverId,
      documentId: active.documentId,
      client: active.client,
      description: active.description,
      collaborator: active.collaborator,
      motiveText: MotiveType.exit.label, // opcional
      motive: MotiveType.exit,
      task: active.task,
      activityType: active.activityType,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp ?? DateTime.now(),
      isSynced: false,
    );

    await isar.writeTxn(() async {
      await isar.activityModels.put(activity);
    });

    return activity;
  }
}
