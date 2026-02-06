// ============================================================================
// NotificationService - Servicio de Notificaciones Locales
// ============================================================================
// Gestiona notificaciones locales programadas para recordar al usuario
// marcar su entrada (8:00 AM) y salida (8:00 PM) diariamente.
// ============================================================================

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  // ─────────────────────────────────────────────────────────────────────────
  // Singleton Pattern
  // ─────────────────────────────────────────────────────────────────────────
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // ─────────────────────────────────────────────────────────────────────────
  // Inicialización
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_isInitialized) {
      debugPrint('🔔 NotificationService ya inicializado');
      return;
    }

    debugPrint('🔔 Inicializando NotificationService...');

    // 1. Inicializar Timezones (CRÍTICO para horarios locales)
    tz.initializeTimeZones();

    // Configurar zona horaria local (América/Lima para Perú, ajusta según necesidad)
    // Si no conoces la zona exacta, usa tz.local que detecta automáticamente
    try {
      final String timeZoneName = await _getLocalTimeZone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('🌍 Zona horaria configurada: $timeZoneName');
    } catch (e) {
      debugPrint('⚠️ No se pudo obtener zona horaria, usando default: $e');
      // Fallback a una zona conocida
      tz.setLocalLocation(tz.getLocation('America/Lima'));
    }

    // 2. Configuración Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // 3. Configuración iOS/macOS
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 4. Combinar configuraciones
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    // 5. Inicializar plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 6. Solicitar permisos (Android 13+ / iOS)
    await _requestPermissions();

    _isInitialized = true;
    debugPrint('✅ NotificationService inicializado correctamente');

    // 7. Programar notificaciones diarias automáticamente
    await scheduleDailyNotifications();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Solicitar Permisos
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _requestPermissions() async {
    // Android 13+ requiere permiso explícito para notificaciones
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final bool? granted =
          await androidPlugin.requestNotificationsPermission();
      debugPrint('🔔 Permiso de notificaciones Android: $granted');

      // También solicitar permiso para alarmas exactas (Android 12+)
      final bool? exactAlarmGranted =
          await androidPlugin.requestExactAlarmsPermission();
      debugPrint('⏰ Permiso de alarmas exactas: $exactAlarmGranted');
    }

    // iOS
    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('🔔 Permisos iOS solicitados');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Programar Notificaciones Diarias
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> scheduleDailyNotifications() async {
    // Cancelar todas las notificaciones pendientes para evitar duplicados
    await _notificationsPlugin.cancelAll();
    debugPrint('🗑️ Notificaciones anteriores canceladas');

    // Detalles de notificación para Android
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'daily_attendance_channel',
      'Recordatorios de Asistencia',
      channelDescription: 'Recordatorios diarios para marcar entrada y salida',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      enableVibration: true,
      playSound: true,
    );

    // Detalles para iOS
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    // ─────────────────────────────────────────────────────────────────────
    // Notificación 8:00 AM - Recordatorio de Entrada
    // ─────────────────────────────────────────────────────────────────────
    await _notificationsPlugin.zonedSchedule(
      1, // ID único para esta notificación
      '¡Buen día! ☀️',
      'No olvides marcar tu entrada en la app de Asistencias.',
      _nextInstanceOfHour(8), // 8:00 AM
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repite diariamente
    );
    debugPrint('⏰ Notificación programada: 8:00 AM (Entrada)');

    // ─────────────────────────────────────────────────────────────────────
    // Notificación 8:00 PM - Recordatorio de Salida
    // ─────────────────────────────────────────────────────────────────────
    await _notificationsPlugin.zonedSchedule(
      2, // ID único para esta notificación
      '¡Hora de salida! 🌙',
      'Recuerda marcar tu salida antes de irte.',
      _nextInstanceOfHour(20), // 8:00 PM (20:00)
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repite diariamente
    );
    debugPrint('⏰ Notificación programada: 8:00 PM (Salida)');

    debugPrint('✅ Notificaciones diarias programadas correctamente');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Calcula la próxima instancia de una hora específica
  tz.TZDateTime _nextInstanceOfHour(int hour) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      0, // minutos
      0, // segundos
    );

    // Si la hora ya pasó hoy, programar para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('📅 Próxima instancia de ${hour}:00 → $scheduledDate');
    return scheduledDate;
  }

  /// Obtiene la zona horaria local del dispositivo
  Future<String> _getLocalTimeZone() async {
    // Para una detección más precisa, podrías usar flutter_timezone package
    // Por ahora usamos una zona por defecto para Perú
    return 'America/Lima';
  }

  /// Callback cuando el usuario toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notificación tocada: ${response.payload}');
    // Aquí podrías navegar a una pantalla específica
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Métodos Públicos Adicionales
  // ─────────────────────────────────────────────────────────────────────────

  /// Muestra una notificación inmediata (útil para testing)
  /// Muestra una notificación inmediata (útil para testing)
  Future<void> showInstantNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'instant_channel',
      'Notificaciones Inmediatas',
      channelDescription: 'Canal para notificaciones instantáneas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(id, title, body, platformDetails);
  }

  /// Cancela todas las notificaciones pendientes
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('🗑️ Todas las notificaciones canceladas');
  }

  /// Cancela una notificación específica por ID
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    debugPrint('🗑️ Notificación $id cancelada');
  }

  /// Obtiene las notificaciones pendientes programadas
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}
