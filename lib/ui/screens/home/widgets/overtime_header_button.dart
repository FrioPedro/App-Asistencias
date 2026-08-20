import 'package:flutter/material.dart';

import 'package:app_asistencias/providers/overtime_provider.dart';
import 'package:app_asistencias/ui/screens/overtime/overtime_requests_screen.dart';

/// Botón del header que abre [OvertimeRequestsScreen], con el conteo de
/// solicitudes pendientes.
class OvertimeHeaderButton extends StatefulWidget {
  const OvertimeHeaderButton({super.key});

  @override
  State<OvertimeHeaderButton> createState() => _OvertimeHeaderButtonState();
}

class _OvertimeHeaderButtonState extends State<OvertimeHeaderButton> {
  static const Color _buttonColor = Color(0xFF2C2C2C);
  static const Color _green = Color(0xFF4CAF50);
  static const Color _amber = Color(0xFFFFB300);
  static const Color _bgColor = Color(0xFF18191D);

  final OvertimeProvider _overtime = OvertimeProvider();

  int _pendingCount = 0;
  int _approvedCount = 0;

  /// Una aprobacion es novedad y tapa a las pendientes; sin novedades, el
  /// badge cuenta lo que falta resolver.
  bool get _hasNews => _approvedCount > 0;

  int get _badgeCount => _hasNews ? _approvedCount : _pendingCount;

  Color get _badgeColor => _hasNews ? _green : _amber;

  /// El ambar necesita texto oscuro para leerse.
  Color get _badgeTextColor => _hasNews ? Colors.white : _bgColor;

  @override
  void initState() {
    super.initState();
    _loadPendingCount();
  }

  Future<void> _loadPendingCount() async {
    try {
      final pending = await _overtime.countPending();
      final approved = await _overtime.countApproved();
      if (!mounted) return;
      setState(() {
        _pendingCount = pending;
        _approvedCount = approved;
      });
    } catch (_) {
      // El badge es informativo: si falla, el botón sigue navegando.
    }
  }

  Future<void> _openRequests() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OvertimeRequestsScreen()),
    );
    await _loadPendingCount();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: _buttonColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.hourglass_empty,
                  color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              tooltip: 'Mis solicitudes de horas extra',
              onPressed: _openRequests,
            ),
          ),
          if (_badgeCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 18),
                decoration: BoxDecoration(
                  color: _badgeColor,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: _bgColor, width: 2),
                ),
                child: Text(
                  _badgeCount > 9 ? '9+' : '$_badgeCount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _badgeTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
