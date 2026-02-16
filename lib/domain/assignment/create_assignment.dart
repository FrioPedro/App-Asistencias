import 'dart:convert';
import 'package:app_asistencias/core/enpoinService.dart';

/// Crea una nueva asignación enviándola al servidor.
/// Ubicado en la capa de dominio siguiendo la arquitectura del proyecto.
class CreateAssignment {
  static final _api = EndpointService.instance;

  /// Envía una nueva asignación al servidor
  static Future<bool> send({
    required String type,
    required String description,
    required String document,
    required String client,
    required List<String> collaborators,
    required String zone,
  }) async {
    try {
      final response = await _api.post('/api/create/projects/v1', data: {
        'type': type,
        'description': description,
        'document': document,
        'client': client,
        'partners': jsonEncode(collaborators),
        'zone': zone,
      });

      print('✅ Asignación creada correctamente: ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error al crear asignación: $e');
      return false;
    }
  }
}
