import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';

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
  final OvertimeProvider _overtime = OvertimeProvider();

  int _pendingCount = 0;
  int _approvedCount = 0;

  /// Una aprobacion es novedad y tapa a las pendientes; sin novedades, el
  /// badge cuenta lo que falta resolver.
  bool get _hasNews => _approvedCount > 0;

  int get _badgeCount => _hasNews ? _approvedCount : _pendingCount;

  Color get _badgeColor => _hasNews ? AppColors.success : AppColors.warning;

  /// Ambar y verde son demasiado claros para texto blanco (1.79:1 y 2.84:1).
  Color get _badgeTextColor => AppColors.onAccent;

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
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.assignment,
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _badgeColor,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.bg, width: 2),
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
