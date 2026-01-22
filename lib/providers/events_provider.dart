import '../models/event_model.dart';

// Esta clase se encarga SOLO de traer los datos.
class EventsProvider {
  
  Future<List<EventModel>> fetchEvents() async {
    try {
      // Simulación de carga (3 segundos)
      await Future.delayed(const Duration(seconds: 3));

      // Retorno de datos de prueba
      return [
        EventModel(
          id: 'ORD-2026-001',
          name: 'MANTENIMIENTO PREVENTIVO',
          company: 'FrioPacking Perú',
          code: 'ORD-2026-001',
          dateTime: 'Hoy, 08:00 AM',
          type: EventType.other,
        ),
        EventModel(
          id: 'ORD-2026-002',
          name: 'INSTALACIÓN DE EQUIPO',
          company: 'Supermercados Méndez',
          code: 'ORD-2026-002',
          dateTime: 'Hoy, 10:30 AM',
          type: EventType.technicalVisit,
        ),
        EventModel(
          id: 'ORD-2026-003',
          name: 'REPARACIÓN DE EMERGENCIA',
          company: 'Hotel Costa',
          code: 'ORD-2026-003',
          dateTime: 'Hoy, 02:00 PM',
          type: EventType.emergency,
        ),
      ];
    } catch (e) {
      print("Error obteniendo eventos: $e");
      return [];
    }
  }
}