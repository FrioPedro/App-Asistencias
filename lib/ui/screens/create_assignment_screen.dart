import 'package:flutter/material.dart';
// --- IMPORTS ---
import '../../models/assignment_model.dart';          // Modelo de datos
import '../../providers/create_assignment_provider.dart'; // Lógica de negocio

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  // 1. Instancia del Provider
  final CreateAssignmentProvider _provider = CreateAssignmentProvider();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;

  // Variables de formulario
  String _selectedClient = 'FRIOPACKING S.A.C.';
  String _selectedAssignmentType = 'VISITA TÉCNICA';
  String _selectedZone = 'SUR';
  
  // Estado de carga para el botón
  bool _isLoading = false;

  final List<String> _availableCollaborators = [
    'Juan Pérez', 'María García', 'Carlos López', 
    'Ana Martínez', 'Roberto Sánchez', 'Diana Flores',
  ];
  
  late Map<String, bool> _selectedCollaborators;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _selectedCollaborators = {
      for (var c in _availableCollaborators) c: false
    };
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE CREACIÓN ---
  Future<void> _submitForm() async {
    // 1. Validar colaboradores
    final selectedList = _getSelectedCollaboratorsList();
    if (selectedList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un colaborador'), backgroundColor: Colors.orange),
      );
      return;
    }

    // 2. Activar carga
    setState(() => _isLoading = true);

    // 3. Crear el objeto Modelo
    final newAssignment = AssignmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      client: _selectedClient,
      type: _selectedAssignmentType,
      zone: _selectedZone,
      description: _descriptionController.text,
      collaborators: selectedList,
      createdAt: DateTime.now(),
    );

    // 4. Llamar al Provider
    final success = await _provider.createAssignment(newAssignment);

    if (mounted) {
      setState(() => _isLoading = false); // Apagar carga

      if (success) {
        // ÉXITO
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Asignación creada exitosamente!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Volver atrás
      } else {
        // ERROR
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear. Intente nuevamente.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el color primario del tema o uno fijo si prefieres

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crear asignación',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CLIENTE
                _buildFormField(
                  label: 'Cliente',
                  child: _buildDropdown(
                    value: _selectedClient,
                    items: ['FRIOPACKING S.A.C.', 'SUPERMERCADOS MÉNDEZ', 'HOTEL COSTA', 'DISTRIBUIDOR ABC', 'FRIGOLATINA'],
                    onChanged: (val) => setState(() => _selectedClient = val!),
                  ),
                ),
                const SizedBox(height: 20),

                // DESCRIPCIÓN
                _buildFormField(
                  label: 'Descripción',
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 4,
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

                // COLABORADORES
                _buildFormField(
                  label: 'Colaboradores',
                  child: GestureDetector(
                    onTap: _showCollaboratorsDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _getSelectedCollaboratorsText(),
                              style: TextStyle(
                                color: _getSelectedCollaboratorsList().isEmpty ? Colors.grey[600] : Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // TIPO
                _buildFormField(
                  label: 'Tipo de asignación',
                  child: _buildDropdown(
                    value: _selectedAssignmentType,
                    items: ['VISITA TÉCNICA', 'MANTENIMIENTO', 'REPARACIÓN', 'INSTALACIÓN'],
                    onChanged: (val) => setState(() => _selectedAssignmentType = val!),
                  ),
                ),
                const SizedBox(height: 20),

                // ZONA
                _buildFormField(
                  label: 'Zona',
                  child: _buildDropdown(
                    value: _selectedZone,
                    items: ['SUR', 'NORTE', 'ESTE', 'OESTE'],
                    onChanged: (val) => setState(() => _selectedZone = val!),
                  ),
                ),
                const SizedBox(height: 40),

                // BOTÓN CREAR
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm, // Deshabilitar si carga
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E60C4), // Azul corporativo
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
                            'CREAR ASIGNACIÓN',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  // Helper para crear Dropdowns genéricos con estilo oscuro
  Widget _buildDropdown({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(12)),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: const Color(0xFF2C2C2C),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 14)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // --- LÓGICA DE COLABORADORES ---

  void _showCollaboratorsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2C2C),
              title: const Text('Seleccionar colaboradores', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _availableCollaborators.map((collaborator) {
                    return CheckboxListTile(
                      value: _selectedCollaborators[collaborator] ?? false,
                      onChanged: (value) {
                        setStateDialog(() {
                          _selectedCollaborators[collaborator] = value ?? false;
                        });
                        // Actualizamos también el estado de la pantalla principal
                        setState(() {}); 
                      },
                      title: Text(collaborator, style: const TextStyle(color: Colors.white)),
                      checkColor: Colors.white,
                      activeColor: const Color(0xFF2E60C4),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Listo', style: TextStyle(color: Color(0xFF2E60C4)))),
              ],
            );
          },
        );
      },
    );
  }

  String _getSelectedCollaboratorsText() {
    final list = _getSelectedCollaboratorsList();
    if (list.isEmpty) return 'Seleccionar colaboradores';
    if (list.length == 1) return list.first;
    return '${list.length} colaboradores seleccionados';
  }

  List<String> _getSelectedCollaboratorsList() {
    return _selectedCollaborators.entries.where((e) => e.value).map((e) => e.key).toList();
  }
}