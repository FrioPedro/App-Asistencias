import 'package:app_asistencias/core/enpoinService.dart';
import 'package:app_asistencias/models/collaborator_model.dart';

/// Obtiene la lista de colaboradores desde la API.
class GetCollaborators {
  /// Retorna todos los colaboradores activos desde el servidor.
  static Future<List<Collaborator>> getAllActive() async {
    try {
      final api = EndpointService.instance;
      final response = await api.get('/api/collaborators');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] as List<dynamic>?) ?? [];

        return data
            .map<Collaborator>((json) => Collaborator.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('❌ Error al obtener colaboradores: $e');
      return [];
    }
  }
}
