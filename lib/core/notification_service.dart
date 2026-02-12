// ============================================================================
// notification_service.dart
// ----------------------------------------------------------------------------
// Servicio singleton para gestionar notificaciones full-screen intent.
// Programa dos recordatorios diarios:
//   • 06:00 AM — Entrada de asistencia
//   • 08:00 PM — Salida de asistencia
//
// Requiere: flutter_local_notifications, flutter_timezone
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:go_router/go_router.dart';

/// Servicio singleton que gestiona las notificaciones locales con
/// full-screen intent para la aplicación de asistencias.
class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Referencia al router para navegar al tocar la notificación.
  static GoRouter? _router;

  // ─── IDs de notificación ────────────────────────────────────────────
  static const int _entradaId = 0;
  static const int _salidaId = 1;

  // ─── Canal de Android ──────────────────────────────────────────────
  static const String _channelId = 'asistencia_channel';
  static const String _channelName = 'Recordatorios de Asistencia';
  static const String _channelDesc =
      'Notificaciones diarias para marcar entrada y salida';

  // ════════════════════════════════════════════════════════════════════
  //  INICIALIZACIÓN
  // ════════════════════════════════════════════════════════════════════

  /// Inicializa el plugin, configura la zona horaria y solicita permisos.
  ///
  /// [router] se usa para navegar a `/home` cuando el usuario toca
  /// la notificación.
  static Future<void> init(GoRouter router) async {
    _router = router;

    // ── Zona horaria local ────────────────────────────────────────────
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // ── Configuración de inicialización ───────────────────────────────
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _instance._plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // ── Solicitar permisos en tiempo de ejecución ─────────────────────
    await _requestPermissions();
  }

  // ════════════════════════════════════════════════════════════════════
  //  PERMISOS
  // ════════════════════════════════════════════════════════════════════

  /// Solicita todos los permisos necesarios para notificaciones
  /// full-screen intent en Android 12+ / 13+ / 14+.
  static Future<void> _requestPermissions() async {
    final androidPlugin = _instance._plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Android 13+ (API 33): Permiso de notificaciones
    await androidPlugin.requestNotificationsPermission();

    // Android 12+ (API 31): Permiso de alarmas exactas
    await androidPlugin.requestExactAlarmsPermission();

    // Android 14+ (API 34): Permiso de full-screen intent
    await androidPlugin.requestFullScreenIntentPermission();
  }

  // ════════════════════════════════════════════════════════════════════
  //  PROGRAMACIÓN DE NOTIFICACIONES
  // ════════════════════════════════════════════════════════════════════

  /// Programa las dos notificaciones diarias recurrentes:
  /// - 06:00 AM → Marca de entrada
  /// - 08:00 PM → Marca de salida
  static Future<void> scheduleDailyNotifications() async {
    // Cancelar notificaciones previamente programadas para evitar duplicados
    await _instance._plugin.cancelAll();

    // ── Notificación de ENTRADA (06:00 AM) ────────────────────────────
    await _scheduleDailyNotification(
      id: _entradaId,
      hour: 10,
      minute: 27,
      title: '¡Hora de trabajar!',
      body: 'Toca aquí para marcar tu asistencia de entrada',
    );

    // ── Notificación de SALIDA (08:00 PM) ─────────────────────────────
    await _scheduleDailyNotification(
      id: _salidaId,
      hour: 20,
      minute: 0,
      title: 'Fin de jornada',
      body: 'Toca aquí para marcar tu salida',
    );

    debugPrint('📅 NotificationService: Notificaciones diarias programadas '
        '(06:00 y 20:00)');
  }

  /// Programa una notificación diaria recurrente a una hora específica.
  static Future<void> _scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      autoCancel: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _instance._plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Calcula la próxima instancia de [hour]:[minute] en la zona local.
  /// Si esa hora ya pasó hoy, devuelve la de mañana.
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
  //  CALLBACK — ACCIÓN AL TOCAR LA NOTIFICACIÓN
  // ════════════════════════════════════════════════════════════════════

  /// Se ejecuta cuando el usuario toca la notificación (normal o
  /// full-screen). Navega a la pantalla de "Marcar Asistencia" (`/home`).
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notificación tocada — payload: ${response.payload}');

    if (_router != null) {
      _router!.go('/home');
    }
  }

  // ════════════════════════════════════════════════════════════════════
  //  UTILIDADES
  // ════════════════════════════════════════════════════════════════════

  /// Cancela todas las notificaciones pendientes.
  static Future<void> cancelAll() async {
    await _instance._plugin.cancelAll();
    debugPrint('🗑️ NotificationService: Todas las notificaciones canceladas');
  }
}
