import 'package:flutter/material.dart';

// --- IMPORTS ---
import '../../../models/assigment_model.dart';
import '../../../providers/events_provider.dart';
import '../../widgets/event_card.dart';
import '../../widgets/event_card_skeleton.dart';
import '../profile_screen.dart';
import '../create_activity_screen.dart';
import '../history_screen.dart';
import '../report_selection_screen.dart';

// Necesario para TaskType
import '../../../models/activity_model.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventsProvider _eventsService = EventsProvider();

  List<AssigmentModel> _assignments = [];
  bool _isLoading = true;
  String _searchQuery = '';

  late TextEditingController _searchController;

  final Map<String, IconData> _participatingEvents = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedAssignments = await _eventsService.fetchEvents();

    // ✅ restaurar turno activo (si existe)
    final active = await _eventsService.getActiveSession();
    if (active != null) {
      final icon = _iconFromTask(active.task);
      _participatingEvents
        ..clear()
        ..[active.eventKey] = icon;
    } else {
      _participatingEvents.clear();
    }

    if (mounted) {
      setState(() {
        _assignments = loadedAssignments;
        _isLoading = false;
      });
    }
  }

  IconData _iconFromTask(TaskType task) {
    switch (task) {
      case TaskType.office:
        return Icons.business;
      case TaskType.workshop:
        return Icons.build;
      case TaskType.service:
        return Icons.construction;
      case TaskType.transport:
        return Icons.local_shipping;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');

    final datePart = isToday ? 'Hoy' : '${date.day}/${date.month}';
    return '$datePart, $hour:$minute $amPm';
  }

  List<AssigmentModel> _filterAssignments() {
    if (_searchQuery.isEmpty) return _assignments;

    return _assignments.where((event) {
      final desc = (event.description ?? '').toLowerCase();
      final client = (event.client ?? '').toLowerCase();
      final docId = (event.documentId ?? '').toLowerCase();

      return desc.contains(_searchQuery) ||
          client.contains(_searchQuery) ||
          docId.contains(_searchQuery);
    }).toList();
  }

  void _startSessionLocal(String eventKey, IconData icon) {
    setState(() {
      _participatingEvents[eventKey] = icon;
    });
  }

  void _endSessionLocal(String eventKey) {
    setState(() {
      _participatingEvents.remove(eventKey);
    });
  }

  TaskType _taskFromTitle(String title) {
    final s = title.trim().toLowerCase();
    if (s == 'oficina') return TaskType.office;
    if (s == 'taller') return TaskType.workshop;
    if (s == 'servicio') return TaskType.service;
    if (s == 'transporte') return TaskType.transport;
    return TaskType.office;
  }

  @override
  Widget build(BuildContext context) {
    final filteredAssignments = _filterAssignments();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: 20,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 10),
              _buildSearchBar(),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? _buildSkeletons()
                    : _buildEventList(filteredAssignments),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletons() {
    return ListView.builder(
      itemCount: 5,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const EventCardSkeleton(),
    );
  }

  Widget _buildEventList(List<AssigmentModel> events) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty
              ? 'No hay asignaciones disponibles'
              : 'No se encontraron resultados',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView(
      children: events.map((event) {
        final String eventKey = event.documentId ?? event.id.toString();

        final bool isParticipating = _participatingEvents.containsKey(eventKey);
        final bool isAnyEventActive = _participatingEvents.isNotEmpty;

        return EventCard(
          eventName: event.description ?? 'Sin descripción',
          companyName: event.client ?? 'Sin cliente',
          eventCode: event.documentId ?? '---',
          dateTime: _formatDate(event.updatedAt),
          assigmentType: event.assigmentType,
          isParticipating: isParticipating,
          actionIcon: _participatingEvents[eventKey],
          onTap: () {
            if (isAnyEventActive && !isParticipating) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Ya tienes un turno activo. Debes marcar salida.'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            _showActionModal(
              context,
              event,
              eventKey,
              isActiveSession: isParticipating,
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              Icons.history,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ),
            ),
            const SizedBox(width: 12),
            _buildHeaderButton(
              Icons.add,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateActivityScreen()),
              ),
            ),
            const SizedBox(width: 12),
            _buildHeaderButton(
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

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
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

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        hintText: 'Buscar...',
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
      ),
    );
  }

  void _showActionModal(
    BuildContext context,
    AssigmentModel event,
    String eventKey, {
    required bool isActiveSession,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 20.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: SingleChildScrollView(
            child: isActiveSession
                ? _buildExitSessionModal(context, event, eventKey)
                : _buildStartSessionModal(context, event, eventKey),
          ),
        );
      },
    );
  }

  Widget _buildStartSessionModal(
    BuildContext context,
    AssigmentModel event,
    String eventKey,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Iniciar Turno',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionOption(context, Icons.business, 'Oficina',
            'Reuniones / Administrativo', event, eventKey),
        const SizedBox(height: 10),
        _buildActionOption(
            context, Icons.build, 'Taller', 'Reparaciones', event, eventKey),
        const SizedBox(height: 10),
        _buildActionOption(context, Icons.local_shipping, 'Transporte',
            'Traslados', event, eventKey),
        const SizedBox(height: 10),
        _buildActionOption(context, Icons.construction, 'Servicio',
            'Visitas técnicas', event, eventKey),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- MODIFICACIÓN AQUÍ ---
  // Este widget ahora filtra la opción que ya está activa
  Widget _buildExitSessionModal(
    BuildContext context,
    AssigmentModel event,
    String eventKey,
  ) {
    // Obtenemos el icono de la actividad actual para compararlo
    final activeIcon = _participatingEvents[eventKey];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gestionar Turno',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Puedes cambiar tu actividad actual o finalizar el turno.',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 20),
        const Text(
          'CAMBIAR ACTIVIDAD',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),

        // Filtramos "Oficina" si ya está activa
        if (activeIcon != Icons.business) ...[
          _buildActionOption(context, Icons.business, 'Oficina',
              'Reuniones / Administrativo', event, eventKey),
          const SizedBox(height: 10),
        ],

        // Filtramos "Taller" si ya está activa
        if (activeIcon != Icons.build) ...[
          _buildActionOption(
              context, Icons.build, 'Taller', 'Reparaciones', event, eventKey),
          const SizedBox(height: 10),
        ],

        // Filtramos "Transporte" si ya está activa
        if (activeIcon != Icons.local_shipping) ...[
          _buildActionOption(context, Icons.local_shipping, 'Transporte',
              'Traslados', event, eventKey),
          const SizedBox(height: 10),
        ],

        // Filtramos "Servicio" si ya está activa
        if (activeIcon != Icons.construction) ...[
          _buildActionOption(context, Icons.construction, 'Servicio',
              'Visitas técnicas', event, eventKey),
          const SizedBox(height: 10),
        ],

        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.assignment),
                label: const Text("REPORTE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ReportSelectionScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("SALIDA"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF5350),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  final sid = event.serverId;
                  if (sid == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('No se puede marcar salida: serverId es null'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  await _eventsService.endAttendance(serverId: sid);

                  _endSessionLocal(eventKey);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Salida registrada'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildActionOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    AssigmentModel event,
    String eventKey,
  ) {
    return GestureDetector(
      onTap: () async {
        final task = _taskFromTitle(title);

        await _eventsService.startAttendance(
          assignment: event,
          task: task,
        );

        _startSessionLocal(eventKey, _iconFromTask(task));
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Participando: $title')));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}