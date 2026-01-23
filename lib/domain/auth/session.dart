import 'package:app_asistencias/domain/token/token.dart';
import 'package:flutter/material.dart';

class Session extends ChangeNotifier {
  String? _token;
  bool _initialized = false;

  bool get isInitialized => _initialized;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> init() async {
    _token = await Token.getToken();
    _initialized = true;
    notifyListeners();
  }

  Future<void> login(String token) async {
    //await Token.saveToken(token);
    _token = token;
    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    await Token.clearToken();
    _token = null;
    notifyListeners();
  }

}

// Instancia global compartida para toda la aplicación
final session = Session();