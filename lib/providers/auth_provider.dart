class AuthProvider {
  /// Simula el inicio de sesión contra una API.
  /// Retorna [true] si el login es exitoso, [false] si falla.
  Future<bool> login(String username, String password) async {
    try {
      // 1. Simular espera de red (2 segundos)
      await Future.delayed(const Duration(seconds: 2));

      // 2. Validación simulada (backend)
      // Aceptamos cualquier usuario que no esté vacío y contraseña mayor a 3 caracteres
      // O puedes hardcodear: if (username == 'admin' && password == '123456')
      if (username.isNotEmpty && password.length >= 4) {
        return true; // Login correcto
      } else {
        return false; // Credenciales incorrectas
      }
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }
}