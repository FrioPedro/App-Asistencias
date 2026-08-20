import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';
import 'package:isar/isar.dart';
import '../models/log_model.dart';
import '../core/database.dart';

class LogProvider {
  /// Obtiene los logs de la base de datos Isar ordenados por fecha (más recientes primero)
  Future<List<LogModel>> fetchLogs() async {
    try {
      final isar = await Database.instance();
      // Obtenemos logs reales ordenados por fecha descendente
      return await isar.logModels.where().sortByTimestampDesc().findAll();
    } catch (e) {
      debugPrint('Error fetching logs: $e');
      return [];
    }
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
        return AppColors.danger; // Rojo suave
      case LogType.warning:
        return AppColors.warning; // Ámbar
      case LogType.info:
        return AppColors.info; // Azul claro
    }
  }
}
