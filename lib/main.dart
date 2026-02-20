import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/services.dart';

import 'package:app_asistencias/core/appRouter.dart';
import 'package:app_asistencias/domain/auth/session.dart';
import 'package:app_asistencias/core/notification_service.dart';
import 'package:app_asistencias/core/permission_guard.dart';

import 'package:app_asistencias/core/sync_worker.dart';

/// Punto de entrada principal de la aplicación
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await session.init(); // ✅ CLAVE: carga token antes del router

  // ✅ Inicializar servicio de notificaciones
  await NotificationService.init(router);

  // ✅ Programar alarmas de trabajo (06:00 AM y 08:00 PM)
  await NotificationService().scheduleDailyWorkReminders();

  // ✅ Iniciar vigilante de alarmas (foreground — sin notificaciones)
  NotificationService().startWatching();

  // ✅ Workmanager init
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // CLAVE: false para ocultar notificaciones
  );

  // Cancelar tareas previas para limpiar configuraciones antiguas (debug)
  await Workmanager().cancelAll();

  // ✅ sync cada 15 min (mínimo de Android)
  // Usamos un ID nuevo 'sync-task-v2' para asegurar una configuración limpia
  await Workmanager().registerPeriodicTask(
    'sync-task-v2',
    kSyncTask,
    frequency: const Duration(minutes: 15), // Android require mín 15 min
    constraints: Constraints(
      networkType: NetworkType.connected, // ✅ wifi o datos móviles
    ),
    existingWorkPolicy: ExistingWorkPolicy.replace, // Reemplazar si existe
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF121212),
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: MyApp()));
}

/// Widget raíz con gestión de ciclo de vida para el AlarmWatcher.
/// - resumed → startWatching (app en primer plano)
/// - paused  → stopWatching (app en background)
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    PermissionGuard.requestCorePermissions();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationService().stopWatching();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App vuelve a primer plano → activar vigilante
      NotificationService().startWatching();
    } else if (state == AppLifecycleState.paused) {
      // App va a background → desactivar vigilante (zonedSchedule se encarga)
      NotificationService().stopWatching();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Asistencia',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF18191D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2E60C4),
          secondary: Color(0xFFFF6D6D),
          error: Color(0xFFFF6D6D),
          surface: Color(0xFF1E1E1E),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E60C4),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
