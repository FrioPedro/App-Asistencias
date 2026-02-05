import 'package:app_asistencias/domain/auth/login_user.dart';
import 'package:app_asistencias/domain/auth/session.dart';


class AuthProvider {
  /// Simula el inicio de sesión contra una API.
  /// Retorna [true] si el login es exitoso, [false] si falla.
  Future<bool> login(String username, String password) async {
    try {
      
      final state = await LoginUser.authenticate(username,password); print(state);
      if (state){
        await session.init(); // Recargamos el token real guardado para activar la sesión
        return true;
      }
      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  
}