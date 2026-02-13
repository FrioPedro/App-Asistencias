// ============================================================================
// reminder_screen.dart
// ----------------------------------------------------------------------------
// Pantalla de recordatorio que se muestra cuando se activa una notificación
// full-screen intent. Muestra el mensaje del recordatorio y permite al
// usuario cerrar la pantalla con el botón "Entendido".
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_asistencias/core/notification_service.dart';

/// Pantalla que se muestra al activarse una notificación de recordatorio
/// con full-screen intent. Diseñada para mostrarse incluso sobre la
/// pantalla de bloqueo.
class ReminderScreen extends StatefulWidget {
  /// Mensaje del recordatorio a mostrar
  final String message;
  final int? notificationId;

  const ReminderScreen({
    super.key,
    required this.message,
    this.notificationId,
  });

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  @override
  void initState() {
    super.initState();
    // Cancelar TODAS las notificaciones — limpiar barra completamente
    NotificationService().cancelAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18191D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Ícono de alarma ──────────────────────────────────────
              const Icon(
                Icons.alarm,
                size: 80,
                color: Color(0xFF2E60C4),
              ),
              const SizedBox(height: 24),

              // ── Título ───────────────────────────────────────────────
              const Text(
                'Recordatorio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // ── Mensaje del recordatorio ────────────────────────────
              Card(
                color: const Color(0xFF1E1E1E),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // ── Botón "Entendido" ────────────────────────────────────
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Cerrar la pantalla y volver a la anterior (o home)
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E60C4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
