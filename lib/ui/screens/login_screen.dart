import 'package:flutter/material.dart';
import 'events_screen.dart';

/// Pantalla de inicio de sesión (Login).
/// Proporciona una interfaz para que el usuario ingrese sus credenciales
/// y acceda a la pantalla de eventos. Incluye:
/// - Logo de la aplicación
/// - Campo de usuario
/// - Campo de contraseña con visibilidad toggle
/// - Botón continuar
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Estado para la pantalla de login.
/// Gestiona:
/// - Visibilidad de la contraseña (toggle seguro/visible)
/// - Validación y navegación de login
class _LoginScreenState extends State<LoginScreen> {
  /// Controla si la contraseña está visible (true) u oculta (false)
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea: Evita que el diseño se superponga con la barra de notificaciones
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Permite scroll si el teclado superpone el botón
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sección 1: Logo de la aplicación
                Image.asset(
                  'assets/images/logo_frioteam.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 80), // Espacio entre logo e inputs

                // Sección 2: Campo de entrada para usuario
                _buildTextField(
                  hintText: 'Usuario',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // Sección 3: Campo de entrada para contraseña
                _buildTextField(
                  hintText: 'Contraseña',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 24),

                // Sección 4: Botón para iniciar sesión y navegar
                SizedBox(
                  width: double.infinity, // Ancho 100%
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navega a la pantalla de eventos
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EventsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0, // Diseño plano (flat)
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 16, 
                        color: Colors.white,
                        fontWeight: FontWeight.bold
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

  /// Construye un campo de texto reutilizable para usuario/contraseña.
  /// 
  /// Parámetros:
  ///   hintText - Texto de ayuda a mostrar en el campo
  ///   icon - Icono del campo
  ///   isPassword - Si es true, oculta el texto (para contraseña)
  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword ? _isObscured : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2C2C2C), // Gris oscuro para inputs
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: Colors.grey[500]),
        // Botón toggle para mostrar/ocultar contraseña
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[500],
                ),
                onPressed: () {
                  // Alterna entre mostrar y ocultar la contraseña
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Sin borde visible
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}