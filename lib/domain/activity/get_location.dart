import 'package:geolocator/geolocator.dart';

class GetLocation {
  
  Future<bool> canUseLocation() async {
    
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ Servicio de ubicación no habilitado");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("⚠️ Permiso de ubicación denegado");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("🚫 Permiso de ubicación denegado permanentemente");
      return false;
    }

    //print("✅ GPS disponible y permisos otorgados");
    return true;
  }

  static Future<Position?> getPrecisePosition({int maxAttempts = 3}) async {
    for (int i = 0; i < maxAttempts; i++) {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            timeLimit: const Duration(seconds: 5),
            forceLocationManager: false,
            distanceFilter: 0,
          ),
        ).timeout(const Duration(seconds: 5));
        if (pos.accuracy <= 50) return pos;
      } catch (_) {}
    }
    return await Geolocator.getLastKnownPosition();
  }

} 