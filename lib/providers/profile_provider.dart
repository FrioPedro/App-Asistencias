import '../models/user_model.dart';
// ✅ IMPORTANTE: Asegúrate de importar el enum UserZone
import '../models/user_zone.dart';

import 'package:app_asistencias/domain/user/get_user.dart';
import 'package:app_asistencias/domain/auth/session.dart';
import 'package:app_asistencias/domain/user/update_user.dart';

import 'package:app_asistencias/domain/user/clear_user.dart';

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

  /// Actualiza la zona del usuario
  /// Recibe un objeto [UserZone] (el enum)
  Future<void> updateZone(UserZone zone) async {
    // Aquí asumo que UpdateUser.updateZone sabe manejar el enum UserZone.
    // Si tu API espera un String, podrías necesitar enviar 'zone.name' o 'zone.label'.
    await UpdateUser.updateZone(zone);
  }

  /// Cierra la sesión actual y notifica a la app
  Future<void> logout() async {
    // 1. Limpiamos datos de usuario local
    await ClearUser.clearLocalData();

    // 2. Cerramos sesión (Token)
    // ✅ CORREGIDO: Usamos 'session' (instancia) en minúscula
    await session.logout();
  }
}
