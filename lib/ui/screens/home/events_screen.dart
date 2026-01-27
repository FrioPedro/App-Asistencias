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
  final Map<String, DateTime> _activeStartTimes = {};
  final Map<String, String> _activeTaskNames = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  // --- 1. FUNCIÓN DE SNACKBAR PERSONALIZADO ---
  void _showCustomSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF252525),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        content: Row(
          children: [
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

  // --- LÓGICA DE VALIDACIÓN DE HORARIO ---
  bool get _isCreationAllowed {
    final now = DateTime.now();
    
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return true;
    }

    final hour = now.hour;
    if (hour >= 6 && hour < 20) {
      return false; // Bloqueado
    }

    return true; 
  }

  void _showRestrictedDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, 
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_filled, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  const Text('Horario Restringido', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text('No se pueden crear actividades en este horario.\n\nHorario permitido:\nLun - Vie: 8:00 PM - 6:00 AM\nSáb - Dom: Todo el día', style: TextStyle(color: Colors.grey[400], fontSize: 16, height: 1.5), textAlign: TextAlign.center),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C2C2C), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendido', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
      case TaskType.office: return Icons.business;
      case TaskType.workshop: return Icons.build;
      case TaskType.service: return Icons.construction;
      case TaskType.transport: return Icons.local_shipping;
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
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
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
      return desc.contains(_searchQuery) || client.contains(_searchQuery) || docId.contains(_searchQuery);
    }).toList();
  }

  void _startSessionLocal(String eventKey, IconData icon, String taskName) {
    setState(() {
      _participatingEvents[eventKey] = icon;
      _activeStartTimes[eventKey] = DateTime.now();
      _activeTaskNames[eventKey] = taskName;
    });
  }

  void _endSessionLocal(String eventKey) {
    setState(() {
      _participatingEvents.remove(eventKey);
      _activeStartTimes.remove(eventKey);
      _activeTaskNames.remove(eventKey);
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

        String timeDisplay = '';
        if (isParticipating && _activeStartTimes.containsKey(eventKey)) {
          timeDisplay = _formatDate(_activeStartTimes[eventKey]!);
        }

        return EventCard(
          eventName: event.description ?? 'Sin descripción',
          companyName: event.client ?? 'Sin cliente',
          eventCode: event.documentId ?? '---',
          dateTime: timeDisplay,
          assigmentType: event.assigmentType,
          isParticipating: isParticipating,
          actionIcon: _participatingEvents[eventKey],
          activeTaskName: _activeTaskNames[eventKey], 
          
          onTap: () {
            if (isAnyEventActive && !isParticipating) {
              _showCustomSnackBar('Ya tienes un turno activo. Debes marcar salida.', isError: true);
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
              () {
                if (!_isCreationAllowed) {
                  _showRestrictedDialog();
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateActivityScreen()),
                );
              },
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

  // --- MODAL DE ACCIONES ---
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
      
      // ✅ 1. BLOQUEAR CIERRE AL TOCAR AFUERA
      isDismissible: false,
      // ✅ 2. BLOQUEAR CIERRE AL DESLIZAR HACIA ABAJO
      enableDrag: false,
      
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        bool isModalLoading = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            
            Future<void> onActivitySelected(String title, IconData icon) async {
              setModalState(() => isModalLoading = true); 

              try {
                final task = _taskFromTitle(title);
                await _eventsService.startAttendance(
                  assignment: event,
                  task: task,
                );

                if (mounted) {
                  _startSessionLocal(eventKey, icon, title);
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  _showCustomSnackBar('Participando: $title', isError: false);
                }
              } catch (e) {
                setModalState(() => isModalLoading = false); 
              }
            }

            Future<void> onExitSelected() async {
              setModalState(() => isModalLoading = true); 

              try {
                final sid = event.serverId;
                if (sid != null) {
                  await _eventsService.endAttendance(serverId: sid);
                  if (mounted) {
                    _endSessionLocal(eventKey);
                  }
                }
                
                if (context.mounted) {
                  Navigator.pop(context);
                  _showCustomSnackBar('Salida registrada', isError: false);
                }
              } catch (e) {
                setModalState(() => isModalLoading = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 20.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
              ),
              child: SingleChildScrollView(
                child: isModalLoading
                    ? const SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Color(0xFF4CAF50)),
                              SizedBox(height: 16),
                              Text("Procesando...", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      )
                    : isActiveSession
                        ? _buildExitSessionModal(
                            context, event, eventKey, onActivitySelected, onExitSelected)
                        : _buildStartSessionModal(
                            context, event, eventKey, onActivitySelected),
              ),
            );
          },
        );
      },
    );
  }

  // ✅ He añadido el botón de cerrar (X) en el Row del título
  Widget _buildStartSessionModal(
    BuildContext context,
    AssigmentModel event,
    String eventKey,
    Function(String, IconData) onOptionSelected, 
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- CABECERA CON BOTÓN CERRAR ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Iniciar Turno',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context), // Permite cerrar manualmente
            ),
          ],
        ),
        // ---------------------------------
        
        const SizedBox(height: 16),
        _buildActionOption(Icons.business, 'Oficina',
            'Reuniones / Administrativo', onOptionSelected),
        const SizedBox(height: 10),
        _buildActionOption(Icons.build, 'Taller', 
            'Reparaciones', onOptionSelected),
        const SizedBox(height: 10),
        _buildActionOption(Icons.local_shipping, 'Transporte', 
            'Traslados', onOptionSelected),
        const SizedBox(height: 10),
        _buildActionOption(Icons.construction, 'Servicio', 
            'Visitas técnicas', onOptionSelected),
        const SizedBox(height: 20),
      ],
    );
  }

  // ✅ He añadido el botón de cerrar (X) en el Row del título
  Widget _buildExitSessionModal(
    BuildContext context,
    AssigmentModel event,
    String eventKey,
    Function(String, IconData) onOptionSelected, 
    VoidCallback onExitSelected,                 
  ) {
    final activeIcon = _participatingEvents[eventKey];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- CABECERA CON BOTÓN CERRAR ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gestionar Turno',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        // ---------------------------------

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

        if (activeIcon != Icons.business) ...[
          _buildActionOption(Icons.business, 'Oficina',
              'Reuniones / Administrativo', onOptionSelected),
          const SizedBox(height: 10),
        ],

        if (activeIcon != Icons.build) ...[
          _buildActionOption(Icons.build, 'Taller', 
              'Reparaciones', onOptionSelected),
          const SizedBox(height: 10),
        ],

        if (activeIcon != Icons.local_shipping) ...[
          _buildActionOption(Icons.local_shipping, 'Transporte',
              'Traslados', onOptionSelected),
          const SizedBox(height: 10),
        ],

        if (activeIcon != Icons.construction) ...[
          _buildActionOption(Icons.construction, 'Servicio',
              'Visitas técnicas', onOptionSelected),
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
                  backgroundColor: const Color(0xFF2C2C2C).withOpacity(0.5), // Más gris/bloqueado
                  foregroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                onPressed: () {
                  // Bloqueado temporalmente
                  // Navigator.pop(context);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (_) => const ReportSelectionScreen()),
                  // );
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
                onPressed: onExitSelected, 
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildActionOption(
    IconData icon,
    String title,
    String subtitle,
    Function(String, IconData) onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(title, icon),
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