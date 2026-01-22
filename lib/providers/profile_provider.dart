import '../models/user_model.dart';

class ProfileProvider {
  
  /// Simula obtener el usuario actual (ya sea de Isar o API)
  Future<UserModel?> getUserProfile() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      // Retornamos el modelo EXACTO de tu compañero
      return UserModel(
        serverId: 1,
        names: 'CARLOS ALEJANDRO',
        lastNames: 'SMITH TAY',
        nationalId: '20230270D',
        zone: 'LIMA - PERÚ',
        token: 'token_de_prueba_123', // Campo obligatorio en su modelo
      );
    } catch (e) {
      print("Error cargando perfil: $e");
      return null;
    }
  }
}