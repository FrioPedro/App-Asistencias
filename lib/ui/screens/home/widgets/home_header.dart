import 'package:flutter/material.dart';
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            'Asignaciones',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Row(
          children: [
            const OvertimeHeaderButton(),
            const SizedBox(width: 12),

            _buildHeaderButton(
              context,
              Icons.history, // Calendario (Historial)
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ),
            ),
            const SizedBox(width: 12),

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
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2C),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: _initials.isNotEmpty
                    ? Text(
                        _initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderButton(
      BuildContext context, IconData icon, VoidCallback onTap) {
    return Container(
      width: 40, // Asegurar tamaño consistente
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20), // Icono ajustado
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }
}
