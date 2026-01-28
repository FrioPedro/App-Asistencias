import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionGuard {
  static Future<bool> checkLocationPermission(BuildContext context) async {
    // 1. Estado del servicio GPS
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        _showDialog(
          context,
          title: 'GPS Desactivado',
          message: 'Es necesario activar el GPS para registrar su asistencia.',
          onSettings: () => Geolocator.openLocationSettings(),
        );
      }
      return false;
    }

    // 2. Permisos de aplicación
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          _showDialog(
            context,
            title: 'Permiso Denegado',
            message: 'La app necesita permiso de ubicación para funcionar.',
            onSettings: () => Geolocator.openAppSettings(),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _showDialog(
          context,
          title: 'Permiso Bloqueado',
          message:
              'El permiso de ubicación está bloqueado permanentemente. Por favor actívalo manualmente en Configuración.',
          onSettings: () => Geolocator.openAppSettings(),
        );
      }
      return false;
    }

    return true;
  }

  static Future<bool> checkCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) return true;

    if (status.isDenied || status.isLimited) {
      final result = await Permission.camera.request();
      if (result.isGranted) return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showDialog(
          context,
          title: 'Cámara Bloqueada',
          message:
              'Necesitamos acceso a la cámara para tomar fotos de evidencia. Ve a Configuración para activarlo.',
          onSettings: () => openAppSettings(),
        );
      }
      return false;
    }

    // Fallback general para denegado
    if (context.mounted) {
      _showDialog(
        context,
        title: 'Permiso Requerido',
        message: 'Se necesita acceso a la cámara.',
        onSettings: () => openAppSettings(),
      );
    }
    return false;
  }

  /// Solicita todos los permisos al inicio y BLOQUEA hasta que se acepten.
  static Future<void> requestAllPermissions(BuildContext context) async {
    bool allGranted = false;

    while (!allGranted) {
      // 1. Pedir Ubicación
      LocationPermission locationStatus = await Geolocator.checkPermission();
      if (locationStatus == LocationPermission.denied) {
        locationStatus = await Geolocator.requestPermission();
      }

      // 2. Pedir Cámara y Storage
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.photos,
        Permission.videos,
        Permission.storage,
      ].request();

      // Verificar si todo está concedido
      final bool isLocationOk = (locationStatus == LocationPermission.always ||
          locationStatus == LocationPermission.whileInUse);

      final bool isCameraOk = (statuses[Permission.camera]?.isGranted ?? false);

      // Si todo está OK, salimos del bucle
      if (isLocationOk && isCameraOk) {
        allGranted = true;
        break;
      }

      // Si falta algo, mostramos diálogo BLOQUEANTE y volvemos a intentar o ir a settings
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false, // No se puede cerrar tocando afuera
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF2C2C2C),
            title: const Text('Permisos Requeridos',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            content: const Text(
                'Para usar la app es OBLIGATORIO aceptar los permisos de:\n\n'
                '📍 Ubicación (para marcar asistencia)\n'
                '📷 Cámara (para evidencias)\n\n'
                'Por favor, acepta los permisos para continuar.',
                style: TextStyle(color: Colors.white70)),
            actions: [
              // No hay botón cancelar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E60C4),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.pop(ctx);

                  // Verificar estado de todos los permisos críticos
                  final bool locDenied =
                      locationStatus == LocationPermission.denied ||
                          locationStatus == LocationPermission.deniedForever;

                  final bool camDenied =
                      statuses[Permission.camera]?.isDenied == true ||
                          statuses[Permission.camera]?.isPermanentlyDenied ==
                              true ||
                          statuses[Permission.camera]?.isRestricted == true;

                  // Si alguno sigue denegado, forzamos ir a configuración
                  if (locDenied || camDenied) {
                    await openAppSettings();
                  }
                  // El bucle while se volverá a ejecutar al volver de settings
                },
                child: const Text('Ir a Configuración'),
              ),
            ],
          ),
        );
      } else {
        // En caso de que el contexto se pierda, salimos para evitar bucle infinito sin UI
        break;
      }
    }
  }

  static void _showDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onSettings,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Cancelar
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E60C4),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onSettings();
            },
            child: const Text('Ir a Configuración'),
          ),
        ],
      ),
    );
  }
}
