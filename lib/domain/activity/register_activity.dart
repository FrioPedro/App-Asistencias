import 'package:geolocator/geolocator.dart';

import 'package:app_asistencias/domain/activity/create_activity.dart';
import 'package:app_asistencias/domain/activity/get_location.dart';
import 'package:app_asistencias/models/assigment_model.dart';
import 'package:app_asistencias/models/taskType_model.dart';

class ActivityRegistrar {
  /// Registra ENTRADA tomando GPS internamente (sin params lat/lng)
  static Future<void> registerEntryWithGPS({
    required AssigmentModel assignment,
    required TaskType task,
    DateTime? timestamp,
  }) async {
    print('[ACTIVITY] registerEntryWithGPS called');
    print('[ACTIVITY] Assignment serverId: ${assignment.serverId}');
    print('[ACTIVITY] Task: $task');
    print('[ACTIVITY] Timestamp override: $timestamp');

    final gps = await _getGpsOrNull();

    if (gps == null) {
      print('[ACTIVITY] GPS not available, saving entry WITHOUT coordinates');
    } else {
      print('[ACTIVITY] GPS obtained: lat=${gps.latitude}, lng=${gps.longitude}');
    }

    await CreateActivity.storeEntry(
      assignment: assignment,
      task: task,
      latitude: gps?.latitude,
      longitude: gps?.longitude,
      timestamp: timestamp,
    );

    print('[ACTIVITY] Entry stored locally');
  }

  /// Registra SALIDA tomando GPS internamente (sin params lat/lng)
  static Future<void> registerExitWithGPS({
    required int serverId,
    DateTime? timestamp,
  }) async {
    print('[ACTIVITY] registerExitWithGPS called');
    print('[ACTIVITY] ServerId: $serverId');
    print('[ACTIVITY] Timestamp override: $timestamp');

    final gps = await _getGpsOrNull();

    if (gps == null) {
      print('[ACTIVITY] GPS not available, saving exit WITHOUT coordinates');
    } else {
      print('[ACTIVITY] GPS obtained: lat=${gps.latitude}, lng=${gps.longitude}');
    }

    await CreateActivity.storeExit(
      serverId: serverId,
      latitude: gps?.latitude,
      longitude: gps?.longitude,
      timestamp: timestamp,
    );

    print('[ACTIVITY] Exit stored locally');
  }

  /// Helper interno: valida permisos/servicio y obtiene posición
  static Future<Position?> _getGpsOrNull() async {
    print('[GPS] Checking location availability');

    final location = GetLocation();

    final canUse = await location.canUseLocation();
    print('[GPS] canUseLocation = $canUse');

    if (!canUse) {
      print('[GPS] Location not allowed or service disabled');
      return null;
    }

    try {
      print('[GPS] Requesting precise position');
      final pos = await GetLocation.getPrecisePosition();

      print(
        '[GPS] Position received: '
        'lat=${pos?.latitude}, lng=${pos?.longitude}, '
        'accuracy=${pos?.accuracy}',
      );

      return pos;
    } catch (e) {
      print('[GPS] Error getting position: $e');
      return null;
    }
  }
}
