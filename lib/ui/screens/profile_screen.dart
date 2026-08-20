import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

import '../../models/user/user_model.dart';
import '../../providers/profile_provider.dart';
import '../../providers/log_provider.dart';
import '../../models/log_model.dart';
import 'log_viewer_screen.dart'; // Ahora en screens

// ✅ Importamos el modelo y la extensión
import '../../models/user/user_zone.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileProvider _profileService = ProfileProvider();

  UserModel? _user;
  bool _isLoading = true;

  // Variable para la zona seleccionada (Texto visible)
  String? _selectedZoneLabel;

  // ✅ Obtenemos las opciones directamente del Enum
  final List<String> _zones = UserZoneX.labels();

  // Variables para el modo desarrollador
  int _tapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // --- 1. FUNCIÓN DE SNACKBAR PERSONALIZADO ---
  void _showCustomSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface, // Fondo Dark
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xs)), // Borde 5px
        content: Row(
          children: [
            // Esfera del ícono
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isError
                    ? AppColors.danger.withOpacity(0.2)
                    : AppColors.success.withOpacity(0.2),
              ),
              child: Icon(
                isError ? Icons.close : Icons.check,
                color: isError ? AppColors.danger : AppColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Texto
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSecretTap() {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(milliseconds: 500)) {
      _tapCount = 0;
    }

    _tapCount++;
    _lastTapTime = now;

    if (_tapCount == 3) {
      _tapCount = 0;
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const LogViewerScreen()));
    }
  }

  Future<void> _loadProfile() async {
    final userLoaded = await _profileService.getUserProfile();

    if (mounted) {
      setState(() {
        _user = userLoaded;
        _isLoading = false;

        // Intentamos matchear la zona que viene del usuario con nuestras etiquetas
        if (userLoaded != null) {
          final zoneEnum = userLoaded.zone.label;
          _selectedZoneLabel = zoneEnum;
        }
      });
    }
  }

  /// ✅ Lógica para guardar el cambio de zona
  Future<void> _updateZone(String newZoneLabel) async {
    setState(() {
      _selectedZoneLabel = newZoneLabel;
      _isLoading = true;
    });

    try {
      // 1. Usamos la extensión para convertir el texto "Sur" -> UserZone.sur
      final zoneEnum = UserZoneX.fromString(newZoneLabel);

      if (zoneEnum != null) {
        // 2. Llamamos al provider
        await _profileService.updateZone(zoneEnum);

        if (mounted) {
          // ✅ Mensaje de Éxito Personalizado
          _showCustomSnackBar('Zona actualizada a: $newZoneLabel',
              isError: false);

          LogProvider.log(
            'Zona actualizada a: $newZoneLabel',
            type: LogType.warning,
            origin: 'ProfileScreen',
          );
        }
      }

      // 3. Recargamos perfil
      await _loadProfile();
    } catch (e) {
      if (mounted) {
        // ❌ Mensaje de Error Personalizado
        _showCustomSnackBar('Error al actualizar zona', isError: true);
        setState(() => _isLoading = false);
      }
      LogProvider.log(
        'Error al actualizar zona a: $newZoneLabel - $e',
        type: LogType.error,
        origin: 'ProfileScreen',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    if (_user == null) {
      return const Center(
          child: Text("Error cargando perfil",
              style: TextStyle(color: Colors.white)));
    }

    final fullName = '${_user?.names ?? ''} ${_user?.lastNames ?? ''}'.trim();
    final document = _user?.nationalId ?? '-';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.gutter),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.surfaceRaised,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xxl),

          _buildInfoTile(
              'Nombres', fullName.isNotEmpty ? fullName : 'Sin Nombre'),
          const SizedBox(height: AppSpacing.lg),
          _buildInfoTile('Documento', document),
          const SizedBox(height: AppSpacing.lg),

          // Selector de Zona
          _buildZoneSelector(),

          const SizedBox(height: AppSpacing.xxl),

          SizedBox(
            width: double.infinity,
            height: AppSpacing.ctaHeight,
            child: ElevatedButton(
              onPressed: () async {
                LogProvider.log(
                  'Cierre de sesión iniciado para el usuario: ${_user?.nationalId ?? 'Desconocido'}',
                  type: LogType.warning,
                  origin: 'ProfileScreen',
                );
                await _profileService.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: const Text(
                'CERRAR SESIÓN',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          GestureDetector(
            onTap: _handleSecretTap,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                "Versión 1.0.3",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildZoneSelector() {
    const cardColor = AppColors.surface;

    final darkDropdownDecoration = CustomDropdownDecoration(
      closedFillColor: cardColor,
      expandedFillColor: cardColor,
      closedBorderRadius: BorderRadius.circular(AppRadius.md),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      headerStyle: const TextStyle(color: Colors.white, fontSize: 16),
      listItemStyle: const TextStyle(color: Colors.white),
      listItemDecoration: const ListItemDecoration(
        selectedColor: Colors.white10,
        highlightColor: Colors.white10,
        splashColor: Colors.white10,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zona',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: AppSpacing.sm),
        CustomDropdown<String>(
          items: _zones,
          initialItem: _selectedZoneLabel,
          hintText: 'Seleccione zona',
          decoration: darkDropdownDecoration,
          onChanged: (value) {
            if (value != null) {
              _updateZone(value);
            }
          },
        ),
      ],
    );
  }
}
