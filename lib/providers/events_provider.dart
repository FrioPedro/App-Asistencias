import 'package:flutter/material.dart';
import '../models/event_model.dart';
// import 'package:http/http.dart' as http; // Descomentar cuando integren backend
// import 'dart:convert';

class EventsProvider extends ChangeNotifier {
  // --- ESTADO ---
  
  // 1. Lista de eventos (Privada)
  List<EventModel> _events = [];
  
  // 2. Estado de carga
  bool _isLoading = true;

  // 3. Mapa de participación (ID -> Icono seleccionado)
  final Map<String, IconData> _participatingEvents = {};

  // --- GETTERS (Para que la UI lea los datos) ---
  
  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  Map<String, IconData> get participatingEvents => _participatingEvents;
  
  // Getter auxiliar para saber si hay ALGUNA sesión activa
  bool get isAnyEventActive => _participatingEvents.isNotEmpty;

  // --- LÓGICA DE CONEXIÓN (FETCH) ---

  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners(); // Avisamos a la UI que muestre los Skeletons

    try {
      // ==================================================================
      // TODO BACKEND: Aquí es donde tu compañero integrará la API
      // ==================================================================
      
      /* CÓDIGO REAL (Ejemplo):
      final response = await http.get(Uri.parse('https://api.tuempresa.com/assignments'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _events = data.map((json) => EventModel.fromJson(json)).toList();
      }
      */

      // --- SIMULACIÓN (TUS DATOS ACTUALES) ---
      await Future.delayed(const Duration(seconds: 3)); // Simulamos espera

      _events = [
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
      // ==================================================================

    } catch (e) {
      debugPrint("Error obteniendo eventos: $e");
      // Aquí podrías manejar errores (ej. lista vacía o mensaje de error)
    } finally {
      _isLoading = false;
      notifyListeners(); // Avisamos a la UI que ya cargó y redibuje la lista real
    }
  }

  // --- LÓGICA DE ACCIONES DE USUARIO ---

  // Iniciar turno (Guardar icono seleccionado)
  void startSession(String eventId, IconData icon) {
    _participatingEvents[eventId] = icon;
    notifyListeners(); // Actualiza la UI instantáneamente
  }

  // Finalizar turno (Remover del mapa)
  void endSession(String eventId) {
    _participatingEvents.remove(eventId);
    notifyListeners();
  }

  // Verificar si participa en un evento específico
  bool isParticipating(String eventId) {
    return _participatingEvents.containsKey(eventId);
  }

  // Obtener el ícono actual de un evento
  IconData? getActionIcon(String eventId) {
    return _participatingEvents[eventId];
  }
}