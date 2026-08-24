import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';
import '../../history_screen.dart';
import '../../profile_screen.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../providers/log_provider.dart';
import '../../../../models/log_model.dart';
import 'overtime_header_button.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  String _initials = '';

  @override
  void initState() {
    super.initState();
    _loadUserInitials();
  }

  Future<void> _loadUserInitials() async {
    try {
      final user = await ProfileProvider().getUserProfile();
      if (user != null) {
        final nameInitial = (user.names != null && user.names!.isNotEmpty)
            ? user.names![0]
            : '';
        final lastNameInitial =
            (user.lastNames != null && user.lastNames!.isNotEmpty)
                ? user.lastNames![0]
                : '';

        if (mounted) {
          setState(() {
            _initials = '$nameInitial$lastNameInitial'.toUpperCase();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user initials: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);

    // 36 es lo maximo que deja los tres controles en la misma fila.
    final titleSize = scaler.scale(28).clamp(28.0, 36.0);

    final buttonSize = scaler.scale(40).clamp(40.0, 64.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Asignaciones',
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Row(
          children: [
            OvertimeHeaderButton(size: buttonSize),
            const SizedBox(width: AppSpacing.md),

            _buildHeaderButton(
              context,
              Icons.history, // Calendario (Historial)
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ),
              buttonSize,
            ),
            const SizedBox(width: AppSpacing.md),

            // Botón de Perfil con Iniciales
            GestureDetector(
              onTap: () {
                LogProvider.log(
                  'Perfil: Abriendo sidebar/perfil',
                  type: LogType.info,
                  origin: 'HomeHeader',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: _initials.isNotEmpty
                    ? Text(
                        _initials,
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: buttonSize * 0.35,
                        ),
                      )
                    : Icon(Icons.person,
                        color: Colors.white, size: buttonSize * 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderButton(
      BuildContext context, IconData icon, VoidCallback onTap, double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size * 0.5),
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }
}
