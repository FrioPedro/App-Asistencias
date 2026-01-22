import 'package:flutter/material.dart';
// AJUSTE: La ruta correcta según tu estructura de carpetas
import 'ui/screens/login_screen.dart'; 

/// Punto de entrada principal de la aplicación
void main() {
  runApp(const MyApp());
}

/// Widget raíz de la aplicación
/// Configura el tema global Dark Mode y la pantalla inicial
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quitar debug de la esquina
      title: 'Asistencia',

      // --- CONFIGURACIÓN DEL TEMA DARK MODE ---
      theme: ThemeData(
        brightness: Brightness.dark, // Modo oscuro base
        useMaterial3: true, // Usar Material Design 3
        
        // Fondo global para todos los Scaffold
        scaffoldBackgroundColor: const Color(0xFF18191D),

        // Paleta de colores personalizada Dark Mode
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2E60C4), // Azul primario
          secondary: Color(0xFFFF6D6D), // Rojo/Salmón secundario
          error: Color(0xFFFF6D6D), // Mismo rojo para errores
          surface: Color(0xFF1E1E1E), // Superficie gris oscuro
        ),
        
        // Estilo global para ElevatedButton (botón principal)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E60C4), // Azul personalizado
            foregroundColor: Colors.white, // Texto blanco
            elevation: 0, // Sin sombra
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Bordes redondeados
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      // Pantalla inicial: LoginScreen
      home: const LoginScreen(),
    );
  }
}