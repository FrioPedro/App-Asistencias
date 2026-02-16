import 'package:flutter/material.dart';
import '../../../models/assigment_model.dart';
import '../../../providers/attendance_provider.dart';
import 'card.dart';
import '../../widgets/event_card_skeleton.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/custom_search_bar.dart';
import '../create_assignment_view.dart';
import 'widgets/restricted_access_dialog.dart';
import '../sheets/event_action_sheet.dart';
import 'widgets/home_header.dart';
import '../../../models/activity/activity_model.dart';
import 'package:app_asistencias/models/taskType_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceProvider _attendanceService = AttendanceProvider();

  List<AssigmentModel> _assignments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final Map<String, IconData> _participatingAttendance = {};
  final Map<String, DateTime> _activeStartTimes = {};
  final Map<String, String> _activeTaskNames = {};
  final Map<String, String> _eventKeyToKeyGroup = {};

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
    final loadedAssignments = await _attendanceService.fetchAssignment();
    final active = await _attendanceService.getActiveSession();

    print('--- LOAD DATA ---');
    print('[ASSIGNMENTS] loaded = ${loadedAssignments.length}');

    if (active == null) {
      print('[ACTIVE] null');
    } else {
      // OJO: ActivityModel NO tiene serverId en tu modelo anterior
      // así que si compila, "serverId" viene de otro modelo distinto.
      print('[ACTIVE] keyGroup="${active.keyGroup}" '
          'assigmentId="${active.serverId}" '
          'timestamp="${active.timestamp}" '
          'task="${active.task}"');
    }

    _participatingAttendance.clear();
    _activeStartTimes.clear();
    _activeTaskNames.clear();
    _eventKeyToKeyGroup.clear();

    if (active != null) {
      final icon = _iconFromTask(active.task);

      // ESTE es el eventKey real de la card (asignación)
      final eventKey = active.serverId.toString();

      _participatingAttendance[eventKey] = icon;
      _activeStartTimes[eventKey] = active.timestamp ?? DateTime.now();
      _activeTaskNames[eventKey] = active.task.label;

      _eventKeyToKeyGroup[eventKey] = active.keyGroup;
    }

    if (mounted) {
      setState(() {
        _assignments = loadedAssignments;
        _isLoading = false;
      });
    }

    print(
        '[MAPS AFTER LOAD] participating=${_participatingAttendance.keys.toList()}');
    print('[MAPS AFTER LOAD] keyGroupMap=$_eventKeyToKeyGroup');
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
      _participatingAttendance[eventKey] = icon;
      _activeStartTimes[eventKey] = DateTime.now();
      _activeTaskNames[eventKey] = taskName;
    });
  }

  void _onSessionEnded(String eventKey) {
    setState(() {
      _participatingAttendance.remove(eventKey);
      _activeStartTimes.remove(eventKey);
      _activeTaskNames.remove(eventKey);
    });
  }

  void _handleCardTap(AssigmentModel event, String eventKey) {
    // Cerramos teclado por si acaso
    FocusScope.of(context).unfocus();

    final bool isParticipating = _participatingAttendance.containsKey(eventKey);
    final bool isAnyEventActive = _participatingAttendance.isNotEmpty;

    print('--- CARD TAP ---');
    print('[TAP] keyGroupMap FULL = $_eventKeyToKeyGroup');
    print(
        '[TAP] containsKey(eventKey) = ${_eventKeyToKeyGroup.containsKey(eventKey)}');
    print('[TAP] lookup direct = ${_eventKeyToKeyGroup[eventKey]}');
    print('[TAP] lookup trimmed = ${_eventKeyToKeyGroup[eventKey.trim()]}');
    print('[TAP] eventKey chars = ${eventKey.runes.toList()}');

    print('[TAP] event.serverId = ${event.serverId}');
    print('[TAP] event.id (local) = ${event.id}');
    print('[TAP] event.documentId = ${event.documentId}');
    print('[TAP] eventKey recibido = "$eventKey"');
    print('[TAP] isParticipating = $isParticipating');
    print('[TAP] isAnyEventActive = $isAnyEventActive');
    print('[TAP] map eventKey->keyGroup = ${_eventKeyToKeyGroup[eventKey]}');
    print(
        '[TAP] participating keys = ${_participatingAttendance.keys.toList()}');

    if (isAnyEventActive && !isParticipating) {
      CustomSnackBar.show(
        context,
        'Ya tienes un turno activo. Debes marcar salida.',
        isError: true,
      );
      return;
    }

    final keyGroupToSend =
        isParticipating ? (_eventKeyToKeyGroup[eventKey] ?? '') : eventKey;

    print('[TAP] keyGroupToSend = "$keyGroupToSend"');
    print('----------------');

    AssigmentModal.show(
      context,
      assignment: event,
      eventKey: eventKey, // "622"
      keyGroup: keyGroupToSend, // "mRZ..."
      isActiveactivity: isParticipating,
      activeIcon: _participatingAttendance[eventKey],
      activeTaskName: _activeTaskNames[eventKey],
      onactivityStarted: (eventKey, keyGroup, icon, taskName) {
        _eventKeyToKeyGroup[eventKey] = keyGroup;
        _onSessionStarted(eventKey, icon, taskName);
      },
      onactivityEnded: (eventKey) {
        _eventKeyToKeyGroup.remove(eventKey);
        _onSessionEnded(eventKey);
      },
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
          if (!_attendanceService.isCreationAllowed()) {
            RestrictedAccessDialog.show(context);
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateAssignmentView()),
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

  Widget _buildEventList(List<AssigmentModel> Attendance) {
    // Definimos el contenido de la lista (vacía con mensaje o con elementos)
    Widget listContent;

    if (Attendance.isEmpty) {
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
        itemCount: Attendance.length,
        itemBuilder: (context, index) {
          final event = Attendance[index];

          // 1) eventKey = llave de la card (documentId)
          final String eventKey = event.serverId.toString();

          // 2) UI: está activo?
          final bool isParticipating =
              _participatingAttendance.containsKey(eventKey);

          // 3) Hora y task
          final String timeDisplay =
              (isParticipating && _activeStartTimes.containsKey(eventKey))
                  ? _formatDate(_activeStartTimes[eventKey]!)
                  : '';

          final String? displayTaskName =
              isParticipating ? _activeTaskNames[eventKey] : null;

          // 4) Si tocan la card y está activa, hay que mandar keyGroup para cerrar
          final String keyToSend = isParticipating
              ? (_eventKeyToKeyGroup[eventKey] ??
                  eventKey) // idealmente siempre existe
              : eventKey;

          // 5) tarea activa global
          String? globalActiveTask;
          if (!isParticipating && _activeTaskNames.isNotEmpty) {
            globalActiveTask = _activeTaskNames.values.first;
          }

          print(
              '[OPEN MODAL] eventKey="$eventKey" isParticipating=$isParticipating '
              'mapKeyGroup="${_eventKeyToKeyGroup[eventKey]}" keyGroupToSend="$keyToSend" '
              'fullMap=$_eventKeyToKeyGroup');

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
