import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

import '../../models/user_model.dart';          
import '../../providers/profile_provider.dart'; 
import 'log_viewer_screen.dart'; // Ahora en screens     

// ✅ Importamos el modelo y la extensión
import '../../models/user_zone.dart'; 

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
        backgroundColor: const Color(0xFF252525), // Fondo Dark
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), // Borde 5px
        content: Row(
          children: [
            // Esfera del ícono
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isError 
                    ? const Color(0xFFFF5252).withOpacity(0.2) 
                    : const Color(0xFF4CAF50).withOpacity(0.2),
              ),
              child: Icon(
                isError ? Icons.close : Icons.check,
                color: isError ? const Color(0xFFFF5252) : const Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
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
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(milliseconds: 500)) {
      _tapCount = 0;
    }
    
    _tapCount++;
    _lastTapTime = now;

    if (_tapCount == 3) {
      _tapCount = 0; 
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LogViewerScreen()));
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
          final zoneEnum = UserZoneX.fromString(userLoaded.zone);
          _selectedZoneLabel = zoneEnum?.label; 
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
          _showCustomSnackBar('Zona actualizada a: $newZoneLabel', isError: false);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
        return const Center(child: Text("Error cargando perfil", style: TextStyle(color: Colors.white)));
    }

    final fullName = '${_user?.names ?? ''} ${_user?.lastNames ?? ''}'.trim();
    final document = _user?.nationalId ?? '-';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 40),

          _buildInfoTile('Nombres', fullName.isNotEmpty ? fullName : 'Sin Nombre'),
          const SizedBox(height: 16),
          _buildInfoTile('Documento', document),
          const SizedBox(height: 16),
          
          // Selector de Zona
          _buildZoneSelector(),
          
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                await _profileService.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'CERRAR SESIÓN',
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          GestureDetector(
            onTap: _handleSecretTap,
            behavior: HitTestBehavior.opaque, 
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "Versión 1.0.2",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(12),
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
    const cardColor = Color(0xFF2C2C2C);
    
    final darkDropdownDecoration = CustomDropdownDecoration(
      closedFillColor: cardColor,
      expandedFillColor: cardColor,
      closedBorderRadius: BorderRadius.circular(12),
      hintStyle: TextStyle(color: Colors.grey[600]),
      headerStyle: const TextStyle(color: Colors.white, fontSize: 16),
      listItemStyle: const TextStyle(color: Colors.white),
      listItemDecoration: ListItemDecoration(
        selectedColor: Colors.white10,
        highlightColor: Colors.white10,
        splashColor: Colors.white10,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zona',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        const SizedBox(height: 8),
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