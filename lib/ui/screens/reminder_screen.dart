// ============================================================================
// reminder_screen.dart
// ----------------------------------------------------------------------------
// Pantalla de recordatorio (full-screen intent)
// - Diseño moderno (gradiente, glow, glass)
// - CTA único: "Entendido" (completa tarea/asistencia + navega a Home)
// - Botón X arriba: cierra y va a Home (sin acciones extra)
// ============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_asistencias/core/notification_service.dart';

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

    // Mejor que cancelar TODO: cancela solo el id si lo tienes
    if (widget.notificationId != null) {
      NotificationService().cancel(widget.notificationId!);
    }

    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulse = CurvedAnimation(parent: _ac, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
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
      // ============================================================
      // AQUÍ VA TU LÓGICA REAL para "cerrar la asistencia / tarea"
      // Ejemplos (elige el que aplique en tu app):
      //
      // await ReminderRepository().markDone(widget.notificationId);
      // await ActivityService().closeReminderTask(...);
      // await NotificationService().ack(widget.notificationId);
      //
      // IMPORTANTE: este paso es el que hace que "sea válido".
      // ============================================================

      // Pequeño delay opcional para que se sienta responsivo (puedes quitarlo)
      // await Future.delayed(const Duration(milliseconds: 150));

      await _goHome();
    } catch (_) {
      // Si falla, igual puedes ir a home o mostrar mensaje. Yo lo dejo simple:
      await _goHome();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundGradient(),
          Positioned(
            top: -120,
            right: -80,
            child: _GlowBlob(
                color: const Color(0xFF2E60C4).withOpacity(0.35), size: 260),
          ),
          Positioned(
            bottom: -140,
            left: -60,
            child: _GlowBlob(
                color: const Color(0xFF8B5CF6).withOpacity(0.22), size: 320),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top bar: hora + X
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          timeStr,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _busy ? null : _goHome, // X => home directo
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.white70,
                        tooltip: "Cerrar",
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, __) {
                            final t = 0.65 + (_pulse.value * 0.35);
                            return Container(
                              width: 108,
                              height: 108,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    const Color(0xFF2E60C4).withOpacity(0.18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2E60C4)
                                        .withOpacity(0.45 * t),
                                    blurRadius: 26 * t,
                                    spreadRadius: 2 * t,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.10),
                                  width: 1.2,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.notifications_active_rounded,
                                  size: 52,
                                  color: Color(0xFFB9D2FF),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Recordatorio',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Tarjeta moderna (sin label “Mensaje”)
                        const _GlassCard(
                          child: Text(
                            'Debes confirmar tu salida para que\n'
                            'tus horas se registren correctamente.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.45,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CTA único: completa + home
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _completeReminderAndGoHome,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF2E60C4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ).copyWith(
                        overlayColor: WidgetStatePropertyAll(
                            Colors.white.withOpacity(0.08)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_busy) ...[
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Procesando...',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800),
                            ),
                          ] else ...[
                            const Icon(Icons.check_circle_rounded, size: 22),
                            const SizedBox(width: 10),
                            const Text(
                              'Entendido',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------- UI helpers ----------------------------

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.25, -0.35),
          radius: 1.15,
          colors: [
            Color(0xFF151A2A),
            Color(0xFF0B0E14),
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
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 70,
              spreadRadius: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: child,
        ),
      ),
    );
  }
}
