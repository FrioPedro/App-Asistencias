import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'package:app_asistencias/core/appRouter.dart';
import 'package:app_asistencias/domain/auth/session.dart';

import 'package:app_asistencias/core/sync_worker.dart';

/// Punto de entrada principal de la aplicación
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await session.init(); // ✅ CLAVE: carga token antes del router

  // ✅ Workmanager init
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // pon false en release
  );

  // ✅ sync cada 1 min (wifi o datos)
  await Workmanager().registerPeriodicTask(
    'sync-task-1',
    kSyncTask,
    frequency: const Duration(minutes: 1),
    constraints: Constraints(
      networkType: NetworkType.connected, // ✅ wifi o datos móviles
    ),
  );

  runApp(const MyApp());
}

/// Widget raíz de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
