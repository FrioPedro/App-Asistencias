import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_asistencias/core/endpointService.dart';
import 'package:app_asistencias/domain/user/get_user.dart';
import 'package:app_asistencias/models/user/user_model.dart';
import 'package:app_asistencias/models/branch_model.dart';

/// Notificador de estado para el usuario actual.
/// Carga el perfil del usuario y proporciona métodos auxiliares
/// como la consulta de sucursales.
class UserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  UserNotifier() : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      // Intenta local primero, si no hay va al API
      UserModel? user = await GetUser.getUserLocal();
      user ??= await GetUser.fetchAndStoreUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      print('❌ Error cargando usuario: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// Obtiene la lista de sucursales/zonas desde la API.
  static Future<List<BranchModel>> getListBranch() async {
    try {
      final api = EndpointService.instance;
      final response = await api.get('/api/branches');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] as List<dynamic>?) ?? [];

        return data
            .map<BranchModel>((json) => BranchModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('❌ Error al obtener sucursales: $e');
      return [];
    }
  }
}

/// Provider global del usuario autenticado.
final userProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<UserModel?>>((ref) {
  return UserNotifier();
});
