import 'package:flutter/material.dart';
import '../../models/user_model.dart';          // El modelo de tu compañero
import '../../providers/profile_provider.dart'; // El provider adaptado

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileProvider _profileService = ProfileProvider();

  UserModel? _user;       
  bool _isLoading = true; 
  bool isAutoExitEnabled = false; 

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
      });
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

    // LÓGICA DE VISUALIZACIÓN
    // Concatenamos nombres y apellidos para mostrar el nombre completo
    final fullName = '${_user?.names ?? ''} ${_user?.lastNames ?? ''}'.trim();
    // Obtenemos el DNI o mostramos guion si es nulo
    final document = _user?.nationalId ?? '-';
    // Obtenemos la zona
    final zone = _user?.zone ?? 'Sin zona';

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

          // Información Personal (Usando los datos procesados arriba)
          _buildInfoTile('Nombres', fullName.isNotEmpty ? fullName : 'Sin Nombre'),
          const SizedBox(height: 16),
          _buildInfoTile('Documento', document),
          const SizedBox(height: 16),
          _buildInfoTile('Zona', zone),
          const SizedBox(height: 16),

          // Toggle Salida Automática
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text(
                'SALIDA AUTOMÁTICA',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              value: isAutoExitEnabled,
              activeThumbColor: Theme.of(context).primaryColor,
              onChanged: (bool value) {
                setState(() {
                  isAutoExitEnabled = value;
                });
              },
            ),
          ),
          const SizedBox(height: 40),

          // Botón Cerrar Sesión
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
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
}