// lib/providers/event_detail_provider.dart

class EventDetailProvider {
  
  /// Simula obtener detalles extendidos de un evento mediante su ID
  Future<Map<String, dynamic>> getExtraDetails(String eventId) async {
    try {
      // 1. Simular espera de red
      await Future.delayed(const Duration(seconds: 1));

      // 2. Retornar datos simulados (Aquí conectarías tu API)
      return {
        'supervisor': 'Ing. Juan Pérez',
        'schedule': '08:00 AM - 05:00 PM',
        'coordinates': {'lat': -12.0464, 'lng': -77.0428}, // Lima
        'description': 'Revisión completa del sistema de refrigeración industrial.',
      };
    } catch (e) {
      print('Error cargando detalles: $e');
      return {};
    }
  }
}