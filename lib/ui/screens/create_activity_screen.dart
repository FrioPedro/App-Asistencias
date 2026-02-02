import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../widgets/custom_snackbar.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({super.key});

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  // --- DATA DUMMY ---
  static const List<String> _clients = [
    'FRIOPACKING S.A.C.',
    'SUPERMERCADOS MÉNDEZ',
    'HOTEL COSTA',
    'DISTRIBUIDOR ABC',
    'FRIGOLATINA',
  ];

  static const List<String> _collaborators = [
    'Juan Pérez',
    'María García',
    'Carlos López',
    'Ana Martínez',
    'Roberto Sánchez',
    'Diana Flores',
  ];

  static const List<String> _zones = ['SUR', 'NORTE', 'ESTE', 'OESTE'];

  static const List<String> _types = ['VST', 'EMG'];
  static const Map<String, String> _typeLabel = {
    'VST': 'VISITA TÉCNICA',
    'EMG': 'EMERGENCIA',
  };

  // --- FORM STATE ---
  String? _selectedClient;
  String _selectedType = 'VST';
  String? _selectedZone;
  List<String> _selectedCollaborators = [];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedClient = _clients.first;
    _selectedZone = _zones.first;

    _showInternetRequirementPopup();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _showInternetRequirementPopup() async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Conexión requerida',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Para crear una asignación es necesario tener conexión a internet activa.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendido',
              style: TextStyle(color: Color(0xFF2E60C4)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedCollaborators.isEmpty) {
      _snack('Selecciona al menos un colaborador', color: Colors.orange);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Confirmar envío',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Deseas crear esta asignación? Asegúrate de que los datos sean correctos.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E60C4),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sí, continuar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _snack('❌ No hay conexión a internet', color: Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 🔹 SIMULACIÓN (DATA DUMMY)
      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;

      _snack('✅ Asignación creada correctamente', color: Colors.green);
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _snack(String msg, {Color? color}) {
    // Usamos el CustomSnackBar para mantener el estilo
    // Si el color es rojo/naranja, asumimos error.
    final isError = color == Colors.red || color == Colors.orange;
    CustomSnackBar.show(context, msg, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF121212);
    const card = Color(0xFF2C2C2C);
    const primary = Color(0xFF2E60C4);

    final darkDropdownDecoration = CustomDropdownDecoration(
      closedFillColor: card,
      expandedFillColor: card,
      closedBorder: Border.all(color: Colors.white12),
      closedBorderRadius: BorderRadius.circular(12),
      hintStyle: TextStyle(color: Colors.grey[600]),
      headerStyle: const TextStyle(color: Colors.white),
      listItemStyle: const TextStyle(color: Colors.white),
      listItemDecoration: ListItemDecoration(
        selectedColor: Colors.white10,
        highlightColor: Colors.white10,
        splashColor: Colors.white10,
      ),
      searchFieldDecoration: SearchFieldDecoration(
        fillColor: card,
        textStyle: const TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crear Actividad',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormField(
                  label: 'Cliente',
                  child: CustomDropdown<String>.search(
                    items: _clients,
                    initialItem: _selectedClient,
                    hintText: 'Seleccione cliente',
                    decoration: darkDropdownDecoration,
                    overlayHeight: 450,
                    onChanged: (value) =>
                        setState(() => _selectedClient = value),
                  ),
                ),
                const SizedBox(height: 20),
                _buildFormField(
                  label: 'Descripción',
                  child: Container(
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 4,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingrese una descripción'
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Ingrese detalles...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildFormField(
                  label: 'Colaboradores',
                  child: CustomDropdown<String>.multiSelectSearch(
                    hintText: 'Seleccionar colaboradores',
                    items: _collaborators,
                    decoration: darkDropdownDecoration,
                    overlayHeight: 420,
                    onListChanged: (values) =>
                        setState(() => _selectedCollaborators = values),
                  ),
                ),
                const SizedBox(height: 20),
                _buildFormField(
                  label: 'Tipo de actividad',
                  child: CustomDropdown<String>(
                    items: _types,
                    initialItem: _selectedType,
                    decoration: darkDropdownDecoration,
                    onChanged: (v) => setState(() => _selectedType = v!),
                    headerBuilder: (context, selectedItem, enabled) {
                      return Text(
                        _typeLabel[selectedItem] ?? selectedItem,
                        style: const TextStyle(color: Colors.white),
                      );
                    },
                    listItemBuilder: (context, item, isSelected, onSelect) {
                      return InkWell(
                        onTap: onSelect,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Text(
                            _typeLabel[item] ?? item,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildFormField(
                  label: 'Zona',
                  child: CustomDropdown<String>(
                    items: _zones,
                    initialItem: _selectedZone,
                    decoration: darkDropdownDecoration,
                    onChanged: (v) => setState(() => _selectedZone = v),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'CREAR ACTIVIDAD',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
