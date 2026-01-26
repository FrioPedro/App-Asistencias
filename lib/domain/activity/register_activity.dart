import 'package:geolocator/geolocator.dart';

import 'package:app_asistencias/domain/activity/create_activity.dart';
import 'package:app_asistencias/domain/activity/get_location.dart';
import 'package:app_asistencias/models/activity_model.dart';
import 'package:app_asistencias/models/assigment_model.dart';

class ActivityRegistrar {
  /// Registra ENTRADA tomando GPS internamente (sin params lat/lng)
  static Future<void> registerEntryWithGPS({
    required AssigmentModel assignment,
    required TaskType task,
    DateTime? timestamp,
  }) async {
    final gps = await _getGpsOrNull();

    await CreateActivity.storeEntry(
      assignment: assignment,
      task: task,
      latitude: gps?.latitude,
      longitude: gps?.longitude,
      timestamp: timestamp,
    );
  }

  /// Registra SALIDA tomando GPS internamente (sin params lat/lng)
  static Future<void> registerExitWithGPS({
    required int serverId,
    DateTime? timestamp,
  }) async {
    final gps = await _getGpsOrNull();

    await CreateActivity.storeExit(
      serverId: serverId,
      latitude: gps?.latitude,
      longitude: gps?.longitude,
      timestamp: timestamp,
    );
  }

  /// Helper interno: valida permisos/servicio y obtiene posición
  static Future<Position?> _getGpsOrNull() async {
    final location = GetLocation();

    final canUse = await location.canUseLocation();
    if (!canUse) return null;

    return await GetLocation.getPrecisePosition();
  }
}
