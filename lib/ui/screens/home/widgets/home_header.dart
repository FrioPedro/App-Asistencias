import 'package:flutter/material.dart';
import '../../history_screen.dart';
import '../../profile_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

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
            _buildHeaderButton(
              context,
              Icons.history,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ),
            ),
            const SizedBox(width: 12),
            _buildHeaderButton(
              context,
              Icons.person,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
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
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onTap,
      ),
    );
  }
}
