import 'package:flutter/material.dart';

// --- IMPORTS ---
import '../../models/event_model.dart';          // Aquí vive el Enum EventType
import '../../providers/events_provider.dart';   // Tu clase simple (sin Provider package)
import '../widgets/event_card.dart';
import '../widgets/event_card_skeleton.dart';
import 'profile_screen.dart';
import 'create_assignment_screen.dart';
import 'history_screen.dart';
import 'report_selection_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  // 1. Instancia de tu servicio (la clase simple)
  final EventsProvider _eventsService = EventsProvider();

  // 2. Estado local de la pantalla
  List<EventModel> _events = [];        // Lista de eventos
  bool _isLoading = true;               // Control de carga
  String _searchQuery = '';             // Texto del buscador
  
  // Controlador del input
  late TextEditingController _searchController;

  // Mapa para controlar participaciones (ID -> Icono)
  final Map<String, IconData> _participatingEvents = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    // 3. Cargamos los datos al iniciar la pantalla
    _loadData();
  }

  // Función asíncrona para pedir datos al servicio
  Future<void> _loadData() async {
    // Llamamos a tu método fetchEvents (que tiene el delay de 3s)
    final loadedEvents = await _eventsService.fetchEvents();

    if (mounted) {
      setState(() {
        _events = loadedEvents;
        _isLoading = false; // Dejamos de mostrar el skeleton
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

  // Filtramos la lista local _events
  List<EventModel> _filterEvents() {
    if (_searchQuery.isEmpty) return _events;
    
    return _events.where((event) {
      final name = event.name.toLowerCase();
      final company = event.company.toLowerCase();
      final code = event.code.toLowerCase();
      return name.contains(_searchQuery) ||
          company.contains(_searchQuery) ||
          code.contains(_searchQuery);
    }).toList();
  }

  // --- MÉTODOS DE ACCIÓN (Gestión de Estado Local) ---

  void _startSessionLocal(String eventId, IconData icon) {
    setState(() {
      _participatingEvents[eventId] = icon;
    });
  }

  void _endSessionLocal(String eventId) {
    setState(() {
      _participatingEvents.remove(eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos la lista filtrada para pintarla
    final filteredEvents = _filterEvents();

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
              // HEADER
              _buildHeader(context),
              
              const SizedBox(height: 10),

              // BUSCADOR
              _buildSearchBar(),
              
              const SizedBox(height: 12),

              // CONTENIDO PRINCIPAL (Skeleton o Lista)
              Expanded(
                child: _isLoading
                    ? _buildSkeletons()
                    : _buildEventList(filteredEvents),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS CONSTRUCTORES ---

  Widget _buildSkeletons() {
    return ListView.builder(
      itemCount: 5,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const EventCardSkeleton(),
    );
  }

  Widget _buildEventList(List<EventModel> events) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty
              ? 'No hay eventos disponibles'
              : 'No se encontraron eventos',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView(
      children: events.map((event) {
        // Verificamos estado en nuestro mapa local
        bool isParticipating = _participatingEvents.containsKey(event.id);
        bool isAnyEventActive = _participatingEvents.isNotEmpty;

        return EventCard(
          eventName: event.name,
          companyName: event.company,
          eventCode: event.code,
          dateTime: event.dateTime,
          eventType: event.type, 
          
          isParticipating: isParticipating,
          actionIcon: _participatingEvents[event.id],
          onTap: () {
            // Validación de exclusividad
            if (isAnyEventActive && !isParticipating) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ya tienes un turno activo. Debes marcar salida.'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            // Abrir el modal correspondiente
            _showActionModal(
              context,
              event.name,
              event.id,
              isActiveSession: isParticipating,
            );
          },
        );
      }).toList(),
    );
  }

  // HEADER (Simplificado para el ejemplo)
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
            _buildHeaderButton(Icons.history, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
            const SizedBox(width: 12),
            _buildHeaderButton(Icons.add, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()))),
            const SizedBox(width: 12),
            _buildHeaderButton(Icons.person, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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

  // --- MODALES Y LÓGICA ---

  void _showActionModal(BuildContext context, String eventName, String eventId, {required bool isActiveSession}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.0, right: 24.0, top: 20.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: SingleChildScrollView(
            child: isActiveSession
                ? _buildExitSessionModal(context, eventId)
                : _buildStartSessionModal(context, eventId),
          ),
        );
      },
    );
  }

  Widget _buildStartSessionModal(BuildContext context, String eventId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Iniciar Turno', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildActionOption(context, Icons.business, 'Oficina', 'Reuniones', eventId),
        const SizedBox(height: 10),
        _buildActionOption(context, Icons.build, 'Taller', 'Reparaciones', eventId),
      ],
    );
  }

  Widget _buildExitSessionModal(BuildContext context, String eventId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Finalizar Turno', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.assignment),
                label: const Text("REPORTE"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C2C2C), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportSelectionScreen()));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("SALIDA"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () {
                  // --- ACCIÓN: FINALIZAR SESIÓN LOCAL ---
                  _endSessionLocal(eventId);
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salida registrada'), backgroundColor: Colors.red));
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildActionOption(BuildContext context, IconData icon, String title, String subtitle, String eventId) {
    return GestureDetector(
      onTap: () {
        // --- ACCIÓN: INICIAR SESIÓN LOCAL ---
        _startSessionLocal(eventId, icon);
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Participando: $title')));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ])),
          ],
        ),
      ),
    );
  }
}