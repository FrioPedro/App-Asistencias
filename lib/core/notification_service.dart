// ============================================================================
// notification_service.dart
// ----------------------------------------------------------------------------
// Sistema de alarma dual:
//
// 1. Foreground (app abierta):
//    Timer.periodic detecta la hora → navega directo a /reminder
//    SIN crear ninguna notificación.
//
// 2. Background (app cerrada/bloqueada):
//    android_alarm_manager_plus ejecuta un callback exacto a nivel del OS
//    → muestra notificación con fullScreenIntent → abre ReminderScreen.
//
// Resultado: comportamiento idéntico al Reloj de Android.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:android_intent_plus/android_intent.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static GoRouter? _router;

  // Canal de alta prioridad para alarmas
  static const String _channelId = 'alarm_noisy_fsi_v3';
  static const String _channelName = 'Alarmas de Trabajo';
  static const String _channelDesc =
      'Alarma con pantalla completa para marcar asistencia';

  // ── Configuración de alarmas ────────────────────────────────────────
  static final List<Map<String, dynamic>> _alarms = [
    {
      'id': 100,
      'hour': 8,
      'minute': 0,
      'title': '¡Hora de trabajar!',
      'body': 'Recuerda marcar tu entrada para comenzar la jornada.',
    },
    {
      'id': 101,
      'hour': 14,
      'minute': 31,
      'title': 'Fin de jornada',
      'body': 'No olvides marcar tu salida antes de irte.',
    },
  ];

  // ── AlarmWatcher (Timer para foreground) ────────────────────────────
  Timer? _watchTimer;
  String? _lastTriggeredKey;

  // ════════════════════════════════════════════════════════════════════
  //  INICIALIZACIÓN
  // ════════════════════════════════════════════════════════════════════

  static Future<void> init(GoRouter router) async {
    _router = router;

    // Timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Plugin de notificaciones (necesario para fullScreenIntent en background)
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);

    await _instance._plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal
    await _createNotificationChannel();

    // Verificar si la app fue lanzada por notificación (FSI desde background)
    final launchDetails =
        await _instance._plugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      debugPrint('🚀 App lanzada por alarma FSI');
      await _instance._plugin.cancelAll();
      if (launchDetails.notificationResponse != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _onNotificationTapped(launchDetails.notificationResponse!);
        });
      }
    }

    // Inicializar AlarmManager
    await AndroidAlarmManager.initialize();

    // Permisos
    await _requestAllPermissions();
  }

  // ════════════════════════════════════════════════════════════════════
  //  CANAL
  // ════════════════════════════════════════════════════════════════════

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.low, // Silencioso / Sin banner
      playSound: false,
      enableVibration: false,
      showBadge: true,
    );

    final androidPlugin = _instance._plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Eliminar canal antiguo para asegurar que se actualice la importancia
    await androidPlugin?.deleteNotificationChannel(_channelId);

    await androidPlugin?.createNotificationChannel(channel);
  }

  // ════════════════════════════════════════════════════════════════════
  //  PERMISOS
  // ════════════════════════════════════════════════════════════════════

  static Future<void> _requestAllPermissions() async {
    debugPrint('🛡️ Verificando permisos...');

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    }

    final androidPlugin = _instance._plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestFullScreenIntentPermission();
    }

    debugPrint('✅ Permisos verificados');
  }

  // ════════════════════════════════════════════════════════════════════
  //  ALARM WATCHER — Timer para foreground (SIN notificaciones)
  // ════════════════════════════════════════════════════════════════════

  void startWatching() {
    stopWatching();

    debugPrint('👁️ AlarmWatcher: Iniciado (cada 15s)');

    // Chequeo inmediato por si la app se acaba de abrir por la alarma
    _checkAlarms();

    _watchTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _checkAlarms();
    });
  }

  void stopWatching() {
    _watchTimer?.cancel();
    _watchTimer = null;
  }

  void _checkAlarms() {
    if (_router == null) return;

    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    for (final alarm in _alarms) {
      final alarmHour = alarm['hour'] as int;
      final alarmMinute = alarm['minute'] as int;

      if (currentHour == alarmHour && currentMinute == alarmMinute) {
        final key = '${alarm['id']}-$currentHour:$currentMinute';
        if (_lastTriggeredKey == key) return;
        _lastTriggeredKey = key;

        final message = alarm['body'] as String;
        final id = alarm['id'] as int;

        debugPrint(
            '⏰ AlarmWatcher: ¡ALARMA! ID:$id a las $currentHour:$currentMinute');

        _plugin.cancelAll();

        final encodedMsg = Uri.encodeComponent(message);
        _router!.go('/reminder?message=$encodedMsg&id=$id');
        return;
      }
    }
  }

  // ════════════════════════════════════════════════════════════════════
  //  PROGRAMACIÓN — AndroidAlarmManager (para background/cerrada)
  // ════════════════════════════════════════════════════════════════════

  /// Programa las alarmas diarias usando AndroidAlarmManager.
  Future<void> scheduleDailyWorkReminders() async {
    for (final alarm in _alarms) {
      final id = alarm['id'] as int;
      final hour = alarm['hour'] as int;
      final minute = alarm['minute'] as int;

      final scheduledTime = _nextInstanceOfDateTime(hour, minute);

      await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        id,
        _alarmCallback,
        exact: true,
        wakeup: true,
        alarmClock: true,
        rescheduleOnReboot: true,
      );

      debugPrint('⏰ Alarma programada ID:$id → '
          '${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")} '
          '(${scheduledTime.toIso8601String()})');
    }

    debugPrint('📅 Todas las alarmas background programadas');
  }

  /// Calcula la próxima ocurrencia de la hora/minuto indicados.
  static DateTime _nextInstanceOfDateTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ════════════════════════════════════════════════════════════════════
  //  CALLBACK ESTÁTICO — Ejecutado por AlarmManager en background
  // ════════════════════════════════════════════════════════════════════

  /// TOP-LEVEL FUNCTION: ejecutada por AlarmManager incluso con app cerrada.
  /// Muestra una notificación con fullScreenIntent que abre la app en /reminder.
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback(int alarmId) async {
    debugPrint('🔔 AlarmManager callback disparado: ID=$alarmId');

    // Buscar los datos de esta alarma
    final alarm = _alarms.firstWhere(
      (a) => a['id'] == alarmId,
      orElse: () => <String, dynamic>{
        'id': alarmId,
        'hour': 0,
        'minute': 0,
        'title': 'Recordatorio',
        'body': 'Tienes un recordatorio pendiente.',
      },
    );

    final title = alarm['title'] as String;
    final body = alarm['body'] as String;

    // 🚀 FUERZA BRUTA: Lanzar la app (Activity) directamente
    // Esto es lo que interrumpe al usuario (como una llamada entrante)
    try {
      debugPrint('🚀 Intentando lanzar Activity...');
      final intent = AndroidIntent(
        package: 'com.friopacking.app_asistencias',
        componentName: 'com.friopacking.app_asistencias.MainActivity',
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.LAUNCHER',
        flags: [
          268435456, // FLAG_ACTIVITY_NEW_TASK
          131072, // FLAG_ACTIVITY_REORDER_TO_FRONT
          67108864, // FLAG_ACTIVITY_CLEAR_TOP
        ],
        // Pasar datos extra para que el router sepa a dónde ir
        arguments: <String, dynamic>{
          'route': '/reminder',
          'payload': body,
          'id': alarmId,
        },
      );
      await intent.launch();
      debugPrint('🚀 Activity lanzada con éxito');
    } catch (e) {
      debugPrint('⚠️ Error lanzando Activity: $e');
    }

    // Siempre mostrar notificación con fullScreenIntent (para background/locked)
    await _showFullScreenNotification(alarmId, title, body);

    // Re-programar la misma alarma para mañana
    final hour = alarm['hour'] as int;
    final minute = alarm['minute'] as int;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final nextTime =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, hour, minute);

    await AndroidAlarmManager.oneShotAt(
      nextTime,
      alarmId,
      _alarmCallback,
      exact: true,
      wakeup: true,
      alarmClock: true,
      rescheduleOnReboot: true,
    );

    debugPrint(
        '🔄 Alarma ID:$alarmId reprogramada → ${nextTime.toIso8601String()}');
  }

  /// Muestra la notificación fullScreenIntent desde el callback de background.
  static Future<void> _showFullScreenNotification(
      int id, String title, String body) async {
    final plugin = FlutterLocalNotificationsPlugin();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);
    await plugin.initialize(initSettings);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.low, // Bajar importancia para evitar banner
      priority: Priority.low, // Bajar prioridad
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      playSound: false, // El sonido lo maneja la UI ahora
      enableVibration: false, // La vibración la maneja la UI
      autoCancel: true,
      ongoing: false,
      timeoutAfter: 60000,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final payload = jsonEncode({
      'type': 'reminder',
      'message': body,
      'id': id,
    });

    await plugin.show(id, title, body, notificationDetails, payload: payload);
    debugPrint('📢 Notificación fullScreenIntent mostrada: ID=$id');
  }

  // ════════════════════════════════════════════════════════════════════
  //  NAVEGACIÓN (cuando el usuario toca la notificación)
  // ════════════════════════════════════════════════════════════════════

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notificación tocada — cancelando inmediatamente');

    if (_router == null) return;

    _instance._plugin.cancelAll();

    try {
      if (response.payload != null && response.payload!.isNotEmpty) {
        final data = jsonDecode(response.payload!);
        final type = data['type'];
        final message = data['message'];
        final rawId = data['id'];
        final int? notifId =
            rawId is int ? rawId : int.tryParse(rawId.toString());

        if (type == 'reminder') {
          final encodedMsg = Uri.encodeComponent(message ?? 'Recordatorio');
          final idParam = notifId != null ? '&id=$notifId' : '';
          _router!.go('/reminder?message=$encodedMsg$idParam');
          return;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error parseando payload: $e');
    }

    _router!.go('/home');
  }

  // ════════════════════════════════════════════════════════════════════
  //  UTILIDADES
  // ════════════════════════════════════════════════════════════════════

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    for (final alarm in _alarms) {
      await AndroidAlarmManager.cancel(alarm['id'] as int);
    }
    debugPrint('🗑️ Todo cancelado (notificaciones + alarmas)');
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
    await AndroidAlarmManager.cancel(id);
  }
}
