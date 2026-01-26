import '../models/user_model.dart';
import 'package:app_asistencias/domain/user/get_user.dart';
import 'package:app_asistencias/domain/auth/session.dart';
import 'package:app_asistencias/domain/user/update_user.dart';
import 'package:app_asistencias/models/user_zone.dart';

class ProfileProvider {
  /// Simula obtener el usuario actual (ya sea de Isar o API)
  Future<UserModel?> getUserProfile() async {
    try {
      // 1️⃣ Intentar obtener local
      final localUser = await GetUser.getUserLocal();
      if (localUser != null) {
        return localUser;
      }

      // 2️⃣ Si no hay local, ir al API y guardar
      final fetchedUser = await GetUser.fetchAndStoreUser();
      if (fetchedUser != null) {
        return fetchedUser;
      }

      // 3️⃣ Si todo falla
      return null;
    } catch (e) {
      print("Error cargando perfil: $e");
      return null;
    }
  }

  Future<void> updateZone(UserZone zone) async {
    await UpdateUser.updateZone(zone);
  }

  /// Cierra la sesión actual y notifica a la app
  Future<void> logout() async {
    await session.logout();
  }
}
