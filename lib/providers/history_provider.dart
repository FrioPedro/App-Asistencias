import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:app_asistencias/models/activity_model.dart';
import 'package:isar/isar.dart';

class HistoryProvider {
  
  /// Obtiene el historial de asignaciones
  /// Retorna una lista de ActivityModel (registros de actividad)
  Future<List<ActivityModel>> fetchHistory() async {
    try {
      // 1. Simulación de espera
      await Future.delayed(const Duration(seconds: 1)); // Reduje el tiempo para probar más rápido

      // 2. Retorno de datos
      final isar = Isar.getInstance();
      if (isar == null) return [];

      return await isar.activityModels.where().sortByTimestampDesc().findAll();
      
    } catch (e) {
      debugPrint("Error cargando historial: $e");
      return [];
    }
  }
}