import 'package:app_asistencias/domain/client/get_clients.dart';
import 'package:app_asistencias/models/client_model.dart';

/// Sincroniza la lista de clientes desde la API.
/// En esta implementación simplificada, sincronizar es equivalente
/// a obtener los datos directamente del servidor ya que los clientes
/// no se almacenan localmente (no son colección Isar).
class SyncClients {
  /// Obtiene los clientes desde el servidor.
  Future<List<Client>> fetchAndSync() async {
    try {
      print('🌐 Sincronizando clientes desde API...');
      final clients = await GetClients.getAllActive();
      print('✅ Clientes sincronizados: ${clients.length}');
      return clients;
    } catch (e) {
      print('❌ Error sincronizando clientes: $e');
      return [];
    }
  }
}
