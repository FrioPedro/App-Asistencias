import 'package:app_asistencias/domain/auth/login_user.dart';

class AuthProvider {
  /// Simula el inicio de sesión contra una API.
  /// Retorna [true] si el login es exitoso, [false] si falla.
  Future<bool> login(String username, String password) async {
    try {
      
      return await LoginUser.authenticate(username,password);
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }
}