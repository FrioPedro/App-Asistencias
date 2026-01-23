import '../models/user_model.dart';
import 'package:app_asistencias/domain/user/get_user.dart';
import 'package:app_asistencias/domain/auth/session.dart';

class ProfileProvider {
  
  /// Simula obtener el usuario actual (ya sea de Isar o API)
  Future<UserModel?> getUserProfile() async {
    try {

      return await GetUser.fetchUser();

    } catch (e) {
      print("Error cargando perfil: $e");
      return null;
    }
  }

  /// Cierra la sesión actual y notifica a la app
  Future<void> logout() async {
    await session.logout();
  }
}