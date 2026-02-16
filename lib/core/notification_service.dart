// ============================================================================
// notification_service.dart
// ----------------------------------------------------------------------------
// Sistema de alarma dual: Timer (foreground) + zonedSchedule (background).
//
// - Foreground: Timer.periodic detecta la hora → navega directo a /reminder
//   SIN crear ninguna notificación.
// - Background/Bloqueado: zonedSchedule + fullScreenIntent abre la Activity
//   → auto-cancela la notificación inmediatamente.
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

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static GoRouter? _router;

  // Canal RUIDOSO — para interrumpir apps activas (YouTube, etc.)
  static const String _channelId = 'alarm_noisy_fsi_v3';
  static const String _channelName = 'Alarmas de Trabajo (Prioridad Alta)';
  static const String _channelDesc =
      'Alarma ruidosa con pantalla completa para garantizar interrupción';

  // ── Configuración de alarmas ────────────────────────────────────────
  // Lista de alarmas: {id, hour, minute, title, body}
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
      'hour': 20,
      'minute': 0, // Hora de prueba actualizada
      'title': 'Fin de jornada',
      'body': 'No olvides marcar tu salida antes de irte.',
    },
  ];

  // ── AlarmWatcher (Timer para foreground) ────────────────────────────
  Timer? _watchTimer;
  // Evitar que la alarma se dispare varias veces en el mismo minuto
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

    // Plugin
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
      // Cancelar TODA notificación inmediatamente
      await _instance._plugin.cancelAll();
      if (launchDetails.notificationResponse != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _onNotificationTapped(launchDetails.notificationResponse!);
        });
      }
    }

    // Permisos
    await _requestAllPermissions();
  }

  // ════════════════════════════════════════════════════════════════════
  //  CANAL (Ruidoso — para garantizar FSI)
  // ════════════════════════════════════════════════════════════════════

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max, // MÁXIMA IMPORTANCIA
      playSound: true, // CON SONIDO
      enableVibration: true, // CON VIBRACIÓN
      audioAttributesUsage: AudioAttributesUsage.alarm, // ATRIBUTO DE ALARMA
      showBadge: true,
    );

    final androidPlugin = _instance._plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
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

  /// Inicia el vigilante de alarmas. Cada 15 segundos compara la hora
  /// actual con las alarmas programadas. Si coincide, navega directo
  /// a /reminder SIN crear ninguna notificación.
  void startWatching() {
    // Evitar múltiples timers
    stopWatching();

    debugPrint('👁️ AlarmWatcher: Iniciado (cada 15s)');
    _watchTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _checkAlarms();
    });
  }

  /// Detiene el vigilante de alarmas (cuando la app va a background).
  void stopWatching() {
    _watchTimer?.cancel();
    _watchTimer = null;
  }

  /// Compara DateTime.now() con cada alarma. Si coincide hora y minuto,
  /// navega directamente a /reminder.
  void _checkAlarms() {
    if (_router == null) return;

    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    for (final alarm in _alarms) {
      final alarmHour = alarm['hour'] as int;
      final alarmMinute = alarm['minute'] as int;

      if (currentHour == alarmHour && currentMinute == alarmMinute) {
        // Clave única para evitar disparar varias veces en el mismo minuto
        final key = '${alarm['id']}-$currentHour:$currentMinute';
        if (_lastTriggeredKey == key) return; // Ya se disparó
        _lastTriggeredKey = key;

        final message = alarm['body'] as String;
        final id = alarm['id'] as int;

        debugPrint(
            '⏰ AlarmWatcher: ¡ALARMA! ID:$id a las $currentHour:$currentMinute');

        // Cancelar cualquier notificación que pudiera haber
        _plugin.cancelAll();

        // Navegar directamente — CERO notificaciones
        final encodedMsg = Uri.encodeComponent(message);
        _router!.go('/reminder?message=$encodedMsg&id=$id');
        return;
      }
    }
  }

  // ════════════════════════════════════════════════════════════════════
  //  PROGRAMACIÓN — zonedSchedule (para background/bloqueado)
  // ════════════════════════════════════════════════════════════════════

  /// Programa las alarmas para cuando la app esté cerrada/en background.
  /// Usa zonedSchedule con fullScreenIntent para despertar la pantalla.
  Future<void> scheduleDailyWorkReminders() async {
    await _plugin.cancelAll();

    for (final alarm in _alarms) {
      await _scheduleBackgroundAlarm(
        id: alarm['id'] as int,
        hour: alarm['hour'] as int,
        minute: alarm['minute'] as int,
        title: alarm['title'] as String,
        body: alarm['body'] as String,
      );
    }

    debugPrint('📅 Alarmas background programadas');
  }

  Future<void> _scheduleBackgroundAlarm({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    // Configuración: máxima prioridad + fullScreenIntent + SONIDO/VIBRACIÓN
    // NECESARIO para que Android permita interrumpir apps activas (como YouTube).
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      // Habilitar sonido y vibración para garantizar interrupción
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      autoCancel: true,
      ongoing: false,
      showProgress: false,
      silent: false, // NO silencioso
      // Timeout: cancelar automáticamente si no se atiende en 60s
      timeoutAfter: 60000,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    final payload = jsonEncode({
      'type': 'reminder',
      'message': body,
      'id': id,
    });

    final scheduledDate = _nextInstanceOfTime(hour, minute);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    debugPrint('⏰ Alarma background ID:$id → '
        '${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")}');
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ════════════════════════════════════════════════════════════════════
  //  NAVEGACIÓN (solo para el caso background/FSI)
  // ════════════════════════════════════════════════════════════════════

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notificación activada — cancelando inmediatamente');

    if (_router == null) return;

    // CANCELAR TODO inmediatamente — limpiar barra
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
    debugPrint('🗑️ Todo cancelado');
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
