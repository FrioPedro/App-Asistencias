import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/services.dart';

import 'package:app_asistencias/core/appRouter.dart';
import 'package:app_asistencias/domain/auth/session.dart';
import 'package:app_asistencias/core/notification_service.dart';
import 'package:app_asistencias/core/permission_guard.dart';

import 'package:app_asistencias/core/sync_worker.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';

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
    systemNavigationBarColor: AppColors.bg,
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
      locale: const Locale('es'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.danger,
          error: AppColors.danger,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 15),
          bodyMedium: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          bodySmall: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          errorStyle: const TextStyle(
            color: AppColors.danger,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.bg,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          contentTextStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            disabledBackgroundColor: AppColors.disabled,
            disabledForegroundColor: AppColors.textSecondary,
            elevation: 0,
            minimumSize: const Size.fromHeight(AppSpacing.ctaHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
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
