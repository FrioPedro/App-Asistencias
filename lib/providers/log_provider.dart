import 'package:flutter/material.dart';
import '../models/log_model.dart';

class LogProvider {
  
  /// Simula la carga de logs del sistema (o base de datos local)
  Future<List<LogModel>> fetchLogs() async {
    // 1. Simular delay de red/lectura
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();

    // 2. Retornar datos simulados variados
    return [
      LogModel(id: '1', message: 'Inicio de sesión exitoso (Usuario: admin)', type: LogType.info, timestamp: now.subtract(const Duration(minutes: 5))),
      LogModel(id: '2', message: 'Sincronización en segundo plano iniciada', type: LogType.info, timestamp: now.subtract(const Duration(minutes: 15))),
      LogModel(id: '3', message: 'Tiempo de espera agotado en API /assignments', type: LogType.warning, timestamp: now.subtract(const Duration(hours: 2))),
      LogModel(id: '4', message: 'Error de conexión: SocketException', type: LogType.error, timestamp: now.subtract(const Duration(hours: 5))),
      
      // Ayer
      LogModel(id: '5', message: 'Base de datos local compactada', type: LogType.info, timestamp: now.subtract(const Duration(days: 1))),
      LogModel(id: '6', message: 'Intento de acceso no autorizado', type: LogType.warning, timestamp: now.subtract(const Duration(days: 1, hours: 4))),
      
      // Semana pasada
      LogModel(id: '7', message: 'Actualización de la app detectada (v1.0.2)', type: LogType.info, timestamp: now.subtract(const Duration(days: 7))),
      LogModel(id: '8', message: 'Fallo crítico en módulo de reportes', type: LogType.error, timestamp: now.subtract(const Duration(days: 7, hours: 2))),
    ];
  }

  /// Filtra una lista de logs según un rango de fechas
  List<LogModel> filterLogsByDate(List<LogModel> logs, DateTimeRange? range) {
    if (range == null) return logs;

    // Ajustamos el rango para incluir todo el día final (hasta las 23:59:59)
    final start = range.start.subtract(const Duration(seconds: 1));
    final end = range.end.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

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
      default:
        return const Color(0xFF42A5F5); // Azul claro
    }
  }
}
