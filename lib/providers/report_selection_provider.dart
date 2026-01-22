import 'package:flutter/material.dart';
import '../models/report_format_model.dart';

class ReportSelectionProvider {
  
  /// Obtiene la lista de formatos de reporte disponibles.
  /// Simula una carga de configuración (podría venir de un JSON remoto).
  Future<List<ReportFormatModel>> getAvailableFormats() async {
    try {
      // 1. Simular carga rápida (500ms es suficiente para menús estáticos)
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. Retornar la configuración
      return [
        ReportFormatModel(title: 'Mantenimiento', icon: Icons.build_circle, color: const Color(0xFF4CAF50)),
        ReportFormatModel(title: 'Instalación', icon: Icons.settings_input_component, color: const Color(0xFF2196F3)),
        ReportFormatModel(title: 'Incidencia', icon: Icons.warning_amber_rounded, color: const Color(0xFFFFC107)),
        ReportFormatModel(title: 'Limpieza', icon: Icons.cleaning_services, color: const Color(0xFF9C27B0)),
        ReportFormatModel(title: 'Inventario', icon: Icons.inventory_2, color: const Color(0xFFFF5722)),
        ReportFormatModel(title: 'Otro', icon: Icons.article, color: const Color(0xFF9E9E9E)),
      ];
    } catch (e) {
      print("Error cargando formatos: $e");
      return [];
    }
  }
}