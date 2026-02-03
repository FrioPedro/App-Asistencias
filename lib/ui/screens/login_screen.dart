import 'package:flutter/material.dart';
import '../../core/permission_guard.dart';
import '../../providers/auth_provider.dart';
import '../../providers/log_provider.dart';
import '../../models/log_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Instanciamos el Provider (Lógica)
  final AuthProvider _authProvider = AuthProvider();

  // 2. Controladores para leer el texto de los inputs
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // 3. Variables de estado visual
  bool _isObscured = true; // Ocultar contraseña
  bool _isLoading = false; // Círculo de carga

  @override
  void dispose() {
    // Limpiamos controladores al salir para liberar memoria
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  /// Método para manejar el proceso de login
  Future<void> _handleLogin() async {
    // Ocultar teclado
    FocusScope.of(context).unfocus();

    // Validaciones básicas antes de llamar al provider
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor ingrese usuario y contraseña'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    // 1. Pedir permisos ANTES de intentar logear
    await PermissionGuard.requestAllPermissions(context);

    // Activar estado de carga
    if (!mounted) return;
    setState(() => _isLoading = true);

    // Llamar al provider
    LogProvider.log(
      'Intento de inicio de sesión iniciado',
      type: LogType.info,
      origin: 'LoginScreen',
    );

    final bool success = await _authProvider.login(
      _userController.text.trim(),
      _passController.text.trim(),
    );

    // Desactivar estado de carga (si el widget sigue vivo)
    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        LogProvider.log(
          'Inicio de sesión exitoso: ${_userController.text}',
          type: LogType.info,
          origin: 'LoginScreen',
        );
        // ÉXITO: El GoRouter redirigirá automáticamente
      } else {
        LogProvider.log(
          'Intento de inicio de sesión fallido: ${_userController.text}',
          type: LogType.warning,
          origin: 'LoginScreen',
        );
        // ERROR: Mostrar mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Credenciales incorrectas'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO
                Image.asset(
                  'assets/images/logo_frioteam.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 80),

                // INPUT USUARIO
                _buildTextField(
                  controller: _userController, // <--- Conectamos controlador
                  hintText: 'Usuario',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // INPUT CONTRASEÑA
                _buildTextField(
                  controller: _passController, // <--- Conectamos controlador
                  hintText: 'Contraseña',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 24),

                // BOTÓN DE LOGIN
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    // Si está cargando, deshabilitamos el botón (null)
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      disabledBackgroundColor:
                          Colors.grey, // Color cuando está deshabilitado
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController
        controller, // <--- Nuevo parámetro obligatorio
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller, // Asignamos el controlador
      obscureText: isPassword ? _isObscured : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: Colors.grey[500]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[500],
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
