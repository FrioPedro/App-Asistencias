import '../models/event_model.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class EventsProvider {
  // Esta función devuelve una "Promesa" (Future) con la lista de eventos
  Future<List<EventModel>> fetchEvents() async {
    try {
      // ==================================================================
      // TODO BACKEND
      // ==================================================================
      
      // Simulación de espera de red
      await Future.delayed(const Duration(seconds: 3));

      // Retornamos la lista simulada
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
      // Si falla, retornamos una lista vacía o lanzamos el error
      print("Error fetching events: $e");
      return [];
    }
  }
}