import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/create_assignment_provider.dart';
import '../../models/client_model.dart';
import '../../models/collaborator_model.dart';
import '../../models/user/user_zone.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import '../../providers/user_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // 🔹 para detectar internet
import '../widgets/custom_snackbar.dart';

class CreateAssignmentView extends ConsumerStatefulWidget {
  const CreateAssignmentView({super.key});

  @override
  ConsumerState<CreateAssignmentView> createState() =>
      _CreateAssignmentViewState();
}

class _CreateAssignmentViewState extends ConsumerState<CreateAssignmentView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String? _selectedClient;
  String? _selectedType = 'VST';
  String? selectedZone;
  List<String> _selectedCollaborators = [];

  late final List<Client> _clients;
  late final List<Collaborator> _collaborators;
  // late final List<BranchModel> _branches; // ⚠️ Reemplazado por lista estática
  final List<String> _fixedZones = const ['Norte', 'Centro', 'Sur'];

  bool isLoading = true;
  bool isSubmitting = false; // 🔹 evita doble clic

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _showInternetRequirementPopup(); // 🔹 mostrar aviso al ingresar
  }

  Future<void> _showInternetRequirementPopup() async {
    await Future.delayed(
        const Duration(milliseconds: 400)); // da tiempo al build

    final connectivityResult = await Connectivity().checkConnectivity();
    if (!mounted) return;

    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Sin conexión'),
          content: const Text(
              'Para crear una asignación es necesario tener conexión a internet activa.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra diálogo
                Navigator.pop(context); // Cierra pantalla
              },
              child: const Text('Volver'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loadInitialData() async {
    final creator = ref.read(assignmentCreatorProvider);
    final user = ref.read(userProvider).value;

    final results = await Future.wait([
      creator.getClients(),
      creator.getCollaborators(),
      // UserNotifier.getListBranch(), // ⚠️ Ya no traemos branches de la API
    ]);

    _clients = results[0] as List<Client>;
    _collaborators = results[1] as List<Collaborator>;
    // _branches = results[2] as List<BranchModel>; // ⚠️ Deshabilitado

    _selectedClient = _clients.isNotEmpty ? _clients.first.description : null;
    _selectedType = 'VST';

    if (user != null) {
      // Intenta hacer match por la zona del usuario (p.ej. "norte" en "Zona Norte")
      final userZoneLabel = user.zone.label.toLowerCase();
      selectedZone = _fixedZones.firstWhere(
        (z) => z.toLowerCase().contains(userZoneLabel),
        orElse: () => 'Centro', // Default a Centro si no match
      );
    } else {
      selectedZone = 'Centro';
    }

    setState(() => isLoading = false);
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // 🔹 Confirmación previa
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar envío'),
        content: const Text(
            '¿Deseas crear esta asignación? Asegúrate de que los datos sean correctos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, continuar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 🔹 Verifica conexión a internet
    final connectivityResult = await Connectivity().checkConnectivity();
    if (!mounted) return;

    if (connectivityResult.contains(ConnectivityResult.none)) {
      CustomSnackBar.show(context, 'No hay conexión a internet', isError: true);
      return;
    }

    // 🔒 Bloquea el botón y muestra carga
    setState(() => isSubmitting = true);

    try {
      final creator = ref.read(assignmentCreatorProvider);

      final client = _clients.firstWhere(
        (c) => c.description == _selectedClient,
        orElse: () => Client()..document = null,
      );

      if (client.document == null) {
        CustomSnackBar.show(context, 'Cliente no válido o no encontrado',
            isError: true);
        return;
      }

      final collaboratorDocs = _collaborators
          .where((c) => _selectedCollaborators.contains(c.name))
          .map((c) => c.document)
          .whereType<String>()
          .toList();

      final success = await creator.createAssignment(
        type: _selectedType!,
        description: _descriptionController.text,
        document: client.document!,
        client: _selectedClient!,
        collaborators: collaboratorDocs,
        zone: selectedZone ?? 'Sin zona',
      );

      if (!mounted) return;

      CustomSnackBar.show(
        context,
        success
            ? 'Asignación creada correctamente'
            : 'Error al crear asignación',
        isError: !success,
      );

      if (success) Navigator.pop(context);
    } finally {
      // 🔓 Habilita el botón otra vez
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final clients =
        _clients.map((c) => c.description).whereType<String>().toList();
    final collaborators =
        _collaborators.map((c) => c.name).whereType<String>().toList();
    // final branchNames = _branches.map((b) => b.name).toList();

    final colorScheme = Theme.of(context).colorScheme;

    final darkDropdownDecoration = CustomDropdownDecoration(
      closedFillColor: colorScheme.surface,
      expandedFillColor: colorScheme.surface,
      closedBorderRadius: BorderRadius.circular(12),
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      headerStyle: TextStyle(color: colorScheme.onSurface),
      listItemStyle: TextStyle(color: colorScheme.onSurface),
      listItemDecoration: ListItemDecoration(
        selectedColor: colorScheme.surfaceContainerHighest,
        highlightColor: colorScheme.surface,
        splashColor: colorScheme.surface.withOpacity(0.3),
      ),
      searchFieldDecoration: SearchFieldDecoration(
        fillColor: colorScheme.surface,
        textStyle: TextStyle(color: colorScheme.onSurface),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Crear Asignación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Cliente:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FormField<String>(
                validator: (value) =>
                    _selectedClient == null ? 'Seleccione un cliente' : null,
                builder: (field) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomDropdown<String>.search(
                        items: clients,
                        initialItem: _selectedClient ??
                            (clients.isNotEmpty ? clients.first : null),
                        onChanged: (value) {
                          setState(() => _selectedClient = value);
                          field.didChange(value);
                        },
                        decoration: darkDropdownDecoration,
                        hintText: 'Seleccione cliente',
                        overlayHeight: 340,
                      ),
                      if (field.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Text(
                            field.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text('Descripción:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingrese una descripción' : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surface,
                  hintText: 'Ingrese una descripción...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Colaboradores:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FormField<List<String>>(
                validator: (values) => (_selectedCollaborators.isEmpty)
                    ? 'Seleccione al menos un colaborador'
                    : null,
                builder: (field) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomDropdown<String>.multiSelectSearch(
                        hintText: 'Seleccionar colaboradores',
                        items: collaborators,
                        onListChanged: (values) {
                          setState(() => _selectedCollaborators = values);
                          field.didChange(values);
                        },
                        decoration: darkDropdownDecoration,
                        overlayHeight: 340,
                      ),
                      if (field.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Text(
                            field.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text('Tipo de Asignación:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'VST', child: Text('VISITA TÉCNICA')),
                  DropdownMenuItem(value: 'EMG', child: Text('EMERGENCIA')),
                ],
                onChanged: (v) => setState(() => _selectedType = v),
              ),
              const SizedBox(height: 20),
              const Text('Zona:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomDropdown<String>.search(
                items: _fixedZones,
                initialItem: selectedZone,
                onChanged: (v) => setState(() => selectedZone = v),
                decoration: darkDropdownDecoration,
                hintText: 'Seleccione zona',
                overlayHeight: 340,
              ),
              const SizedBox(height: 30),
              Center(
                child: isSubmitting
                    ? const CircularProgressIndicator() // 🔄 carga mientras envía
                    : ElevatedButton.icon(
                        onPressed: _onSubmit,
                        icon: const Icon(
                          Icons.save_alt_rounded,
                          color: Colors.white,
                        ),
                        label: const Text('Generar Asignación',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
