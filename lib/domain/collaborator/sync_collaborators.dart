import 'package:app_asistencias/domain/collaborator/get_collaborators.dart';
import 'package:app_asistencias/models/collaborator_model.dart';

/// Sincroniza la lista de colaboradores desde la API.
/// Implementación simplificada ya que los colaboradores no se persisten
/// localmente en Isar.
class SyncCollaborators {
  /// Obtiene los colaboradores desde el servidor.
  Future<List<Collaborator>> fetchAndSync() async {
    try {
      print('🌐 Sincronizando colaboradores desde API...');
      final collaborators = await GetCollaborators.getAllActive();
      print('✅ Colaboradores sincronizados: ${collaborators.length}');
      return collaborators;
    } catch (e) {
      print('❌ Error sincronizando colaboradores: $e');
      return [];
    }
  }
}
