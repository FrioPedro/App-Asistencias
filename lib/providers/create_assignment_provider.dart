import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/assignment/create_assignment.dart';
import '../domain/client/get_clients.dart';
import '../domain/client/sync_clients.dart';
import '../domain/collaborator/get_collaborators.dart';
import '../domain/collaborator/sync_collaborators.dart';
import '../models/client_model.dart';
import '../models/collaborator_model.dart';

/// 🔹 Provider clase principal
class AssignmentCreatorProvider {
  final Ref ref;
  AssignmentCreatorProvider(this.ref);

  /// 🔸 Obtiene todos los clientes locales (si está vacío, sincroniza)
  Future<List<Client>> getClients({bool forceSync = false}) async {
    var local = await GetClients.getAllActive();

    if (local.isEmpty || forceSync) {
      print('🌐 Sincronizando clientes desde API...');
      local = await SyncClients().fetchAndSync();
    }

    return local;
  }

  /// 🔸 Obtiene todos los colaboradores locales (si está vacío, sincroniza)
  Future<List<Collaborator>> getCollaborators({bool forceSync = false}) async {
    var local = await GetCollaborators.getAllActive();

    if (local.isEmpty || forceSync) {
      print('🌐 Sincronizando colaboradores desde API...');
      local = await SyncCollaborators().fetchAndSync();
    }

    return local;
  }

  /// 🔸 Crea una asignación nueva (envío al servidor)
  Future<bool> createAssignment({
    required String type,
    required String description,
    required String document,
    required String client,
    required List<String> collaborators,
    required String zone,
  }) async {
    print('📝 Enviando nueva asignación...');
    return await CreateAssignment.send(
      type: type,
      description: description,
      document: document,
      client: client,
      collaborators: collaborators,
      zone: zone,
    );
  }
}

final assignmentCreatorProvider = Provider<AssignmentCreatorProvider>((ref) => AssignmentCreatorProvider(ref));