import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../models/log_model.dart';
import '../core/database.dart';

class LogProvider {
  /// Obtiene los logs de la base de datos Isar
  Future<List<LogModel>> fetchLogs() async {
    final isar = await Database.instance();
    final logs = await isar.logModels.where().sortByTimestampDesc().findAll();

    if (logs.isEmpty) {
      // Si no hay logs reales, generamos algunos de prueba
      return _generateMockLogs();
    }
    return logs;
  }

  /// Genera logs de prueba
  List<LogModel> _generateMockLogs() {
    final now = DateTime.now();

    // 2. Retornar datos simulados variados
    return [
      LogModel(
          message: 'Inicio de sesión exitoso (Usuario: admin)',
          type: LogType.info,
          timestamp: now.subtract(const Duration(minutes: 5))),
      LogModel(
          message: 'Sincronización en segundo plano iniciada',
          type: LogType.info,
          timestamp: now.subtract(const Duration(minutes: 15))),
      LogModel(
          message: 'Tiempo de espera agotado en API /assignments',
          type: LogType.warning,
          timestamp: now.subtract(const Duration(hours: 2))),
      LogModel(
          message: 'Error de conexión: SocketException',
          type: LogType.error,
          timestamp: now.subtract(const Duration(hours: 5))),

      // Ayer
      LogModel(
          message: 'Base de datos local compactada',
          type: LogType.info,
          timestamp: now.subtract(const Duration(days: 1))),
      LogModel(
          message: 'Intento de acceso no autorizado',
          type: LogType.warning,
          timestamp: now.subtract(const Duration(days: 1, hours: 4))),

      // Semana pasada
      LogModel(
          message: 'Actualización de la app detectada (v1.0.2)',
          type: LogType.info,
          timestamp: now.subtract(const Duration(days: 7))),
      LogModel(
          message: 'Fallo crítico en módulo de reportes',
          type: LogType.error,
          timestamp: now.subtract(const Duration(days: 7, hours: 2))),
    ];
  }

  /// Guarda un nuevo log en la base de datos
  static Future<void> log(
    String message, {
    LogType type = LogType.info,
    String? origin,
    String? stackTrace,
    String? userId,
    String? appVersion,
  }) async {
    try {
      final isar = await Database.instance();
      final newLog = LogModel(
        message: message,
        type: type,
        timestamp: DateTime.now(),
        origin: origin,
        stackTrace: stackTrace,
        userId: userId,
        appVersion: appVersion,
      );

      await isar.writeTxn(() async {
        await isar.logModels.put(newLog);
      });
    } catch (e) {
      debugPrint('Error saving log: $e');
    }
  }

  /// Filtra una lista de logs según un rango de fechas
  List<LogModel> filterLogsByDate(List<LogModel> logs, DateTimeRange? range) {
    if (range == null) return logs;

    // Ajustamos el rango para incluir todo el día final (hasta las 23:59:59)
    final start = range.start.subtract(const Duration(seconds: 1));
    final end = range.end
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    return logs.where((log) {
      return log.timestamp.isAfter(start) && log.timestamp.isBefore(end);
    }).toList();
  }

  /// Helper para obtener color según el tipo
  Color getColorByType(LogType type) {
    switch (type) {
      case LogType.error:
        return const Color(0xFFEF5350); // Rojo suave
      case LogType.warning:
        return const Color(0xFFFFCA28); // Ámbar
      case LogType.info:
        return const Color(0xFF42A5F5); // Azul claro
    }
  }
}
