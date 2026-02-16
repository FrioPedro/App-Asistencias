// ============================================================================
// reminder_screen.dart
// ----------------------------------------------------------------------------
// Pantalla de recordatorio (full-screen intent) - Rediseño Profesional
// - Reloj grande centrado
// - Fondo gradiente elegante
// - Deslizar para confirmar (usando Dismissible nativo para evitar errores de build)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_asistencias/core/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class ReminderScreen extends StatefulWidget {
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

class _ReminderScreenState extends State<ReminderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _pulse;
  bool _busy = false;

  @override
  void initState() {
    super.initState();

    if (widget.notificationId != null) {
      NotificationService().cancel(widget.notificationId!);
    }

    // 🔊 Reproducir sonido de alarma en bucle y vibración
    FlutterRingtonePlayer().playAlarm(
      looping: true, // Bucle infinito hasta que se cierre
      asAlarm: true, // Usar canal de alarma (respeta volumen)
      volume: 1.0, // Volumen máximo
    );

    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulse = CurvedAnimation(parent: _ac, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    FlutterRingtonePlayer().stop(); // Detener sonido al salir
    _ac.dispose();
    super.dispose();
  }

  Future<void> _goHome() async {
    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _completeReminderAndGoHome() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      // Simula proceso de cierre/confirmación
      await Future.delayed(const Duration(milliseconds: 300));
      await _goHome();
    } catch (_) {
      await _goHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formato de hora AM/PM o 24h según prefieras. Aquí uso HH:mm
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Fondo base
      body: Stack(
        children: [
          // 1. Fondo con Gradiente Animado (simulado estático por performance)
          const _BackgroundGradient(),

          // 2. Elementos decorativos (Blobs)
          Positioned(
            top: -100,
            left: -50,
            child: _GlowBlob(
                color: const Color(0xFF3B82F6).withOpacity(0.2), size: 300),
          ),
          Positioned(
            bottom: -80,
            right: -20,
            child: _GlowBlob(
                color: const Color(0xFF8B5CF6).withOpacity(0.15), size: 250),
          ),

          SafeArea(
            child: Column(
              children: [
                // Cabecera sutil vacía para balance
                const SizedBox(height: 60),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono animado
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, __) {
                          return Transform.scale(
                            scale: 1.0 + (_pulse.value * 0.05),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 40),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.indigo.withOpacity(0.1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.indigoAccent
                                        .withOpacity(0.2 * _pulse.value),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.access_alarm_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),

                      // HORA GRANDE
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 86,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                          letterSpacing: -2,
                          height: 1,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Mensaje principal
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // SLIDER "DESLIZAR PARA CONFIRMAR" (Nativo con Dismissible)
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 50),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Texto de fondo
                        const Center(
                          child: Text(
                            'Desliza para confirmar  >>>',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        // Slider real
                        Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.startToEnd,
                          dismissThresholds: const {
                            DismissDirection.startToEnd: 0.6
                          },
                          confirmDismiss: (direction) async {
                            await _completeReminderAndGoHome();
                            return false; // No eliminar del árbol widget
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 4),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(2, 0),
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF0F172A),
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------- UI Helper Widgets ----------------------------

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A), // Slate 900
            Color(0xFF1E293B), // Slate 800
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          // Reemplazo de ImageFilter.blur por BoxShadow equivalente
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 60,
              spreadRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}
