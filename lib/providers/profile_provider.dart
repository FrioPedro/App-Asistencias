import '../models/user_model.dart';

class ProfileProvider {
  
  /// Simula obtener el usuario actual (ya sea de Isar o API)
  Future<UserModel?> getUserProfile() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      // Retornamos el modelo EXACTO de tu compañero
      return UserModel(
        names: 'CARLOS ALEJANDRO',
        lastNames: 'SMITH TAY',
        nationalId: '20230270D',
        zone: 'LIMA - PERÚ',
      );
    } catch (e) {
      print("Error cargando perfil: $e");
      return null;
    }
  }
}