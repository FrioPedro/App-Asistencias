import 'package:flutter/material.dart';
import '../../../models/assigment_model.dart';
import '../../../providers/events_provider.dart';
import 'card.dart';
import '../../widgets/event_card_skeleton.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/custom_search_bar.dart';
import '../create_activity_screen.dart';
import 'widgets/restricted_access_dialog.dart';
import '../sheets/event_action_sheet.dart';
import 'widgets/home_header.dart';
import '../../../models/activity/activity_model.dart';

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
  final TextEditingController _searchController = TextEditingController();

  final Map<String, IconData> _participatingEvents = {};
  final Map<String, DateTime> _activeStartTimes = {};
  final Map<String, String> _activeTaskNames = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final loadedAssignments = await _eventsService.fetchEvents();
    final active = await _eventsService.getActiveSession();

    if (active != null) {
      final icon = _iconFromTask(active.task);
      _participatingEvents.clear();
      _activeStartTimes.clear();
      _activeTaskNames.clear();

      _participatingEvents[active.eventKey] = icon;
      _activeStartTimes[active.eventKey] = active.timestamp;
      _activeTaskNames[active.eventKey] = active.task.label;
    } else {
      _participatingEvents.clear();
      _activeStartTimes.clear();
      _activeTaskNames.clear();
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

  void _onSessionStarted(String eventKey, IconData icon, String taskName) {
    setState(() {
      _participatingEvents[eventKey] = icon;
      _activeStartTimes[eventKey] = DateTime.now();
      _activeTaskNames[eventKey] = taskName;
    });
  }

  void _onSessionEnded(String eventKey) {
    setState(() {
      _participatingEvents.remove(eventKey);
      _activeStartTimes.remove(eventKey);
      _activeTaskNames.remove(eventKey);
    });
  }

  void _handleCardTap(AssigmentModel event, String eventKey) {
    // Cerramos teclado por si acaso
    FocusScope.of(context).unfocus();

    final bool isParticipating = _participatingEvents.containsKey(eventKey);
    final bool isAnyEventActive = _participatingEvents.isNotEmpty;

    if (isAnyEventActive && !isParticipating) {
      CustomSnackBar.show(
          context, 'Ya tienes un turno activo. Debes marcar salida.',
          isError: true);
      return;
    }

    // Usamos el método estático del widget extraído
    EventActionModal.show(
      context,
      event: event,
      eventKey: eventKey,
      isActiveSession: isParticipating,
      activeIcon: _participatingEvents[eventKey],
      activeTaskName: _activeTaskNames[eventKey],
      onSessionStarted: _onSessionStarted,
      onSessionEnded: _onSessionEnded,
    );
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
              const HomeHeader(),
              const SizedBox(height: 10),
              CustomSearchBar(
                controller: _searchController,
                onChanged: (val) =>
                    setState(() => _searchQuery = val.toLowerCase()),
              ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_eventsService.isCreationAllowed()) {
            RestrictedAccessDialog.show(context);
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateActivityScreen()),
          );
        },
        backgroundColor: const Color(0xFF2E60C4),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
    // Definimos el contenido de la lista (vacía con mensaje o con elementos)
    Widget listContent;

    if (events.isEmpty) {
      // Usamos ListView con un solo hijo que ocupa todo el espacio para permitir el scroll y el refresh
      listContent = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'No hay asignaciones disponibles'
                    : 'No se encontraron resultados',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
        ],
      );
    } else {
      listContent = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final String eventKey = event.documentId ?? event.id.toString();
          final bool isParticipating =
              _participatingEvents.containsKey(eventKey);

          String timeDisplay = '';
          if (isParticipating && _activeStartTimes.containsKey(eventKey)) {
            timeDisplay = _formatDate(_activeStartTimes[eventKey]!);
          }

          // Determinar nombre de tarea para mostrar
          String? displayTaskName; // Null por defecto (estado vacío)
          if (isParticipating) {
            displayTaskName = _activeTaskNames[eventKey];
          }

          // Buscar si hay alguna tarea activa en OTRO evento
          String? globalActiveTask;
          if (!isParticipating && _activeTaskNames.isNotEmpty) {
            globalActiveTask = _activeTaskNames.values.first;
          }

          return EventCard(
            eventName: event.description ?? 'Sin descripción',
            taskName: displayTaskName,
            companyName: event.client ?? 'Sin cliente',
            eventCode: event.documentId ?? '---',
            startTime: timeDisplay,
            assigmentType: event.assigmentType,
            isParticipating: isParticipating,
            activeTaskName: globalActiveTask,
            onTap: () => _handleCardTap(event, eventKey),
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF2E60C4),
      backgroundColor: const Color(0xFF2C2C2C),
      child: listContent,
    );
  }
}
