import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart'; // <--- 1. IMPORTAR ESTO

import '../../models/user_model.dart';          
import '../../providers/profile_provider.dart'; 
import '../widgets/log_viewer_screen.dart';     

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileProvider _profileService = ProfileProvider();

  UserModel? _user;       
  bool _isLoading = true; 
  
  // 2. Variable para la zona seleccionada
  String? _selectedZone;
  
  // 3. Lista de opciones
  static const List<String> _zones = ['Norte', 'Sur', 'Este', 'Oeste'];

  // Variables para el modo desarrollador (Triple Tap)
  int _tapCount = 0;
  DateTime? _lastTapTime;

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

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userLoaded = await _profileService.getUserProfile();
    
    if (mounted) {
      setState(() {
        _user = userLoaded;
        _isLoading = false;
        
        // 4. Inicializar la zona seleccionada con la del usuario
        // Aseguramos que coincida con la lista, o seleccionamos la primera si no coincide
        if (userLoaded != null && _zones.contains(userLoaded.zone)) {
          _selectedZone = userLoaded.zone;
        } else {
          _selectedZone = null; // O _zones.first por defecto
        }
      });
    }
  }

  // Lógica para guardar el cambio de zona (Opcional: conectar con API)
  Future<void> _updateZone(String newZone) async {
    setState(() {
      _selectedZone = newZone;
    });
    // AQUÍ: Podrías llamar a _profileService.updateZone(newZone) si existiera esa función
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Zona cambiada a: $newZone')),
    );
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
          // Avatar
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 40),

          // Información Personal
          _buildInfoTile('Nombres', fullName.isNotEmpty ? fullName : 'Sin Nombre'),
          const SizedBox(height: 16),
          _buildInfoTile('Documento', document),
          const SizedBox(height: 16),
          
          // 5. Selector de Zona (Reemplaza al tile fijo)
          _buildZoneSelector(),
          
          const SizedBox(height: 40),

          // Botón Cerrar Sesión
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

          // Texto de versión
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

  // Widget para campos de solo lectura
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

  // 6. Nuevo Widget para el Dropdown de Zona
  Widget _buildZoneSelector() {
    const cardColor = Color(0xFF2C2C2C);
    
    // Configuración de estilo igual a tu app
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
          initialItem: _selectedZone,
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