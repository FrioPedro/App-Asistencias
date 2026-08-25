import 'package:app_asistencias/core/endpointService.dart';
import 'package:app_asistencias/models/client_model.dart';

/// Obtiene la lista de clientes desde la API.
class GetClients {
  /// Retorna todos los clientes activos desde el servidor.
  static Future<List<Client>> getAllActive() async {
    try {
      final api = EndpointService.instance;
      final response = await api.get('/api/clients');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] as List<dynamic>?) ?? [];

        return data.map<Client>((json) => Client.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('❌ Error al obtener clientes: $e');
      return [];
    }
  }
}
