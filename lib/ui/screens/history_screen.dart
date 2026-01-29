import 'package:flutter/material.dart';

// --- IMPORTS ACTUALIZADOS ---
import '../../models/activity_model.dart'; // Usamos ActivityModel para el historial
import '../../models/assigment_model.dart'; // Import para AssigmentType
import '../../providers/history_provider.dart'; // Provider actualizado
import '../widgets/event_card_history.dart'; // Importamos la nueva tarjeta de historial
import '../widgets/event_card_skeleton.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/calendar_modal.dart'; // Nuevo modal de calendario

// --- MODELO AUXILIAR PARA AGRUPACIÓN (Clase Privada) ---
class _HistorySession {
  ActivityModel? entry;
  ActivityModel? exit;

  _HistorySession({this.entry, this.exit});

  // Helpers para obtener datos comunes
  String get description =>
      entry?.description ?? exit?.description ?? 'Sin descripción';
  String get client => entry?.client ?? exit?.client ?? 'Sin cliente';
  String get documentId => entry?.documentId ?? exit?.documentId ?? '---';
  String get taskLabel => entry?.task.label ?? exit?.task.label ?? 'Oficina';

  DateTime get sortDate =>
      entry?.timestamp ?? exit?.timestamp ?? DateTime.now();

  // Cálculo de tiempos
  String? get entryTime {
    if (entry == null) return null;
    return _formatTime(entry!.timestamp);
  }

  String? get exitTime {
    if (exit == null) return null;
    return _formatTime(exit!.timestamp);
  }

  bool get hasPendingSync =>
      (entry != null && entry!.isSynced == false) ||
      (exit != null && exit!.isSynced == false);

  static String _formatTime(DateTime d) {
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final amPm = d.hour >= 12 ? 'PM' : 'AM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '$hour:$minute $amPm';
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // 1. Instanciamos el servicio
  final HistoryProvider _historyService = HistoryProvider();

  // 2. Estado
  late TextEditingController _searchController;
  String _searchQuery = '';
  bool _isLoading = true;

  // Filtro
  DateTime?
      _selectedDate; // Null = Sin filtro (o todos) o hoy? El user quiere filtro inicial? Asumamos null o hoy.

  // Lista de nuevos modelos
  List<ActivityModel> _allActivities = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    // Inicializar con la fecha de hoy por defecto si se desea, o null si quiere ver todo.
    // El user dijo "a pena presionas el dia se filtre", asi que iniciamos con Hoy para ser útiles o todo?
    // Generalmente historia es "todo", pero si filtramos por día, mejor null inicialmente o Hoy.
    _selectedDate = DateTime.now();

    // Carga inicial
    _loadData();
  }

  /// Pide los datos al Provider
  Future<void> _loadData() async {
    final loadedActivities = await _historyService.fetchHistory();
    if (mounted) {
      setState(() {
        _allActivities = loadedActivities;
        _isLoading = false;
      });
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

  void _openCalendarModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalendarModal(
        initialDate: _selectedDate ?? DateTime.now(),
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
      ),
    );
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
  }

  // --- LÓGICA DE AGRUPACIÓN (Entry + Exit) ---
  List<_HistorySession> _groupActivities(List<ActivityModel> rawActivities) {
    // 1. Nos aseguramos que estén ordenados del MÁS RECIENTE al MÁS ANTIGUO
    // (Asumimos que timestamp es confiable)
    final sorted = List<ActivityModel>.from(rawActivities);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final List<_HistorySession> sessions = [];
    final Map<String, List<_HistorySession>> openExits = {};

    for (var activity in sorted) {
      // Clave única para agrupar sesión: Documento + Tarea + (Opcional: Cliente)
      // Esto previene mezclar Entry de Taller con Exit de Oficina
      final key = '${activity.documentId}_${activity.task.index}';

      if (activity.motive == MotiveType.exit) {
        // ENCONTRAMOS SALIDA (Reciente)
        // Creamos una sesión "abierta por arriba" (tiene fin, busca inicio)
        final session = _HistorySession(exit: activity);
        sessions.add(session);

        // La registramos para esperar su entrada
        if (!openExits.containsKey(key)) {
          openExits[key] = [];
        }
        openExits[key]!.add(session);
      } else {
        // ENCONTRAMOS ENTRADA (Más antigua)
        // Buscamos si hay un Exit esperando
        if (openExits.containsKey(key) && openExits[key]!.isNotEmpty) {
          // Emparejamos con el Exit más reciente encontrado (el último agregado a la pila)
          final session = openExits[key]!.removeLast();
          session.entry = activity;
        } else {
          // Entrada sin salida futura (Es la actividad actual o olvidó marcar salida)
          final session = _HistorySession(entry: activity);
          sessions.add(session);
        }
      }
    }

    return sessions;
  }

  // --- LÓGICA DE FILTRADO ---
  List<_HistorySession> _getFilteredSessions() {
    final grouped = _groupActivities(_allActivities);

    return grouped.where((session) {
      // 1. Filtro de Texto
      final desc = session.description.toLowerCase();
      final client = session.client.toLowerCase();
      final docId = session.documentId.toLowerCase();

      final matchesText = _searchQuery.isEmpty ||
          desc.contains(_searchQuery) ||
          client.contains(_searchQuery) ||
          docId.contains(_searchQuery);

      if (!matchesText) return false;

      // 2. Filtro de Fecha (DÍA ÚNICO)
      if (_selectedDate != null) {
        final activityDate = session.sortDate;

        final isSameDay = activityDate.year == _selectedDate!.year &&
            activityDate.month == _selectedDate!.month &&
            activityDate.day == _selectedDate!.day;

        if (!isSameDay) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSessions = _getFilteredSessions();
    final isDateFilterActive = _selectedDate != null;

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
          'Histórico',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BUSCADOR Y BOTÓN CALENDARIO ---
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomSearchBar(
                      controller: _searchController,
                      hintText: 'Buscar actividad',
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.toLowerCase()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón Calendario Restaourado
                  Container(
                    decoration: BoxDecoration(
                      color: isDateFilterActive
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon:
                          const Icon(Icons.calendar_month, color: Colors.white),
                      onPressed: _openCalendarModal,
                    ),
                  ),
                ],
              ),
            ),

            // --- CHIP FILTRO (Solo si hay fecha seleccionada) ---
            if (isDateFilterActive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Filtrando: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: const TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _clearDateFilter,
                            child: const Icon(Icons.close,
                                color: Color(0xFF4CAF50), size: 18),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // --- LISTA ---
            Expanded(
              child: _isLoading
                  ? _buildSkeletons()
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: const Color(0xFF2E60C4),
                      backgroundColor: const Color(0xFF2C2C2C),
                      child: filteredSessions.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.event_busy,
                                            size: 60, color: Colors.grey[800]),
                                        const SizedBox(height: 16),
                                        Text(
                                            isDateFilterActive
                                                ? 'No hay actividades para esta fecha'
                                                : 'No se encontraron actividades',
                                            style: TextStyle(
                                                color: Colors.grey[600])),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: filteredSessions.length,
                              itemBuilder: (context, index) {
                                final session = filteredSessions[index];

                                return EventCard(
                                  eventName: session.description,
                                  companyName: session.client,
                                  eventCode: session.documentId,
                                  taskName: session.taskLabel,
                                  entryTime: session.entryTime,
                                  exitTime: session.exitTime,
                                  hasPendingSync: session.hasPendingSync,
                                  assigmentType: session.entry?.activityType ??
                                      AssigmentType.other,
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletons() {
    return ListView.builder(
      itemCount: 5,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return const EventCardSkeleton();
      },
    );
  }
}
