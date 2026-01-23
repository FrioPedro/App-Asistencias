import 'package:flutter/foundation.dart'; // Para debugPrint
import '../models/assigment_model.dart'; // Importamos el nuevo modelo

class HistoryProvider {
  
  /// Obtiene el historial de asignaciones
  /// Retorna una lista de AssigmentModel (tu nuevo modelo)
  Future<List<AssigmentModel>> fetchHistory() async {
    try {
      // 1. Simulación de espera
      await Future.delayed(const Duration(seconds: 1)); // Reduje el tiempo para probar más rápido

      // 2. Retorno de datos
      
      return [
        AssigmentModel(
          serverId: 101,
          documentId: 'ORD-2026-001',
          client: 'FrioPacking Perú',
          description: 'MANTENIMIENTO PREVENTIVO',
          assigmentType: AssigmentType.other, // OTR
        )..updatedAt = DateTime.now(), // Asignamos fecha

        AssigmentModel(
          serverId: 102,
          documentId: 'ORD-2026-002',
          client: 'Supermercados Méndez',
          description: 'INSTALACIÓN DE EQUIPO',
          assigmentType: AssigmentType.technicalVisit, // VST
        )..updatedAt = DateTime.now().subtract(const Duration(hours: 2)),
      ];
      
    } catch (e) {
      debugPrint("Error cargando historial: $e");
      return [];
    }
  }
}