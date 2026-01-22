import '../models/event_model.dart';

class HistoryProvider {
  
  /// Simula la petición para traer el historial de eventos
  Future<List<EventModel>> fetchHistory() async {
    try {
      // 1. Simulación de carga (3 segundos)
      await Future.delayed(const Duration(seconds: 3));

      // 2. Retornamos la lista mezclada (Pasados y Futuros)
      return [
        // Eventos Recientes/Futuros
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
        // Eventos Pasados (Histórico)
        EventModel(
          id: 'ORD-2026-100',
          name: 'MANTENIMIENTO CORRECTIVO',
          company: 'Distribuidor ABC',
          code: 'ORD-2026-100',
          dateTime: 'Ayer, 09:00 AM',
          type: EventType.emergency,
        ),
        EventModel(
          id: 'ORD-2026-099',
          name: 'REVISIÓN TÉCNICA',
          company: 'Frigolín',
          code: 'ORD-2026-099',
          dateTime: '20/01/2026, 03:00 PM',
          type: EventType.technicalVisit,
        ),
      ];
    } catch (e) {
      print("Error cargando historial: $e");
      return [];
    }
  }
}