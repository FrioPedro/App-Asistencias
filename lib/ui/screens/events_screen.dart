import 'package:flutter/material.dart';

// --- IMPORTS ---
import '../../models/assigment_model.dart';      // <--- TU NUEVO MODELO
import '../../providers/events_provider.dart';   // Asegúrate de que este provider retorne List<AssigmentModel>
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
  // 1. Instancia de tu servicio
  final EventsProvider _eventsService = EventsProvider();

  // 2. Estado local de la pantalla
  List<AssigmentModel> _events = [];    // <--- AHORA ES LISTA DE ASSIGMENTMODEL
  bool _isLoading = true;
  String _searchQuery = '';
  
  late TextEditingController _searchController;
  
  // Mapa para controlar participaciones (ID -> Icono)
  // Usamos el ID del servidor o el ID local como String
  final Map<String, IconData> _participatingEvents = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    // 3. Cargamos los datos
    _loadData();
  }

  Future<void> _loadData() async {
    // El provider debe devolver Future<List<AssigmentModel>>
    final loadedEvents = await _eventsService.fetchEvents();

    if (mounted) {
      setState(() {
        _events = loadedEvents;
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

  // Helper para formatear fecha (DateTime -> String "Hoy, 08:00 AM")
  String _formatDate(DateTime date) {
    // Aquí puedes usar intl, pero para mantenerlo simple y sin librerías:
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    
    final datePart = isToday ? 'Hoy' : '${date.day}/${date.month}';
    return '$datePart, $hour:$minute $amPm';
  }

  // Filtramos la lista local
  List<AssigmentModel> _filterEvents() {
    if (_searchQuery.isEmpty) return _events;
    
    return _events.where((event) {
      // Usamos los nuevos campos con Null Check (?? '')
      final desc = (event.description ?? '').toLowerCase();
      final client = (event.client ?? '').toLowerCase();
      final docId = (event.documentId ?? '').toLowerCase();
      
      return desc.contains(_searchQuery) ||
          client.contains(_searchQuery) ||
          docId.contains(_searchQuery);
    }).toList();
  }

  // --- MÉTODOS DE ACCIÓN ---

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

              // CONTENIDO
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
        // Usamos documentId como clave única, o el ID de Isar convertido a String
        final String uniqueId = event.documentId ?? event.id.toString();

        bool isParticipating = _participatingEvents.containsKey(uniqueId);
        bool isAnyEventActive = _participatingEvents.isNotEmpty;

        return EventCard(
          // Mapeo de campos nuevos a la tarjeta
          eventName: event.description ?? 'Sin descripción',
          companyName: event.client ?? 'Sin cliente',
          eventCode: event.documentId ?? '---',
          dateTime: _formatDate(event.updatedAt), // Formateamos el DateTime
          
          // Pasamos el nuevo Enum (asegúrate de actualizar EventCard también)
          assigmentType: event.assigmentType, 
          
          isParticipating: isParticipating,
          actionIcon: _participatingEvents[uniqueId],
          onTap: () {
            if (isAnyEventActive && !isParticipating) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ya tienes un turno activo. Debes marcar salida.'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            _showActionModal(
              context,
              event.description ?? '',
              uniqueId,
              isActiveSession: isParticipating,
            );
          },
        );
      }).toList(),
    );
  }

  // HEADER
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

  // --- MODALES ---

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

  // MODAL INICIO (Con tus 4 opciones)
  Widget _buildStartSessionModal(BuildContext context, String eventId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Iniciar Turno', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildActionOption(context, Icons.business, 'Oficina', 'Reuniones / Administrativo', eventId),
        const SizedBox(height: 10),
        _buildActionOption(context, Icons.build, 'Taller', 'Reparaciones', eventId),
        const SizedBox(height: 10),
        _buildActionOption(context, Icons.local_shipping, 'Transporte', 'Traslados', eventId),
        const SizedBox(height: 10),
        _buildActionOption(context, Icons.construction, 'Servicio', 'Visitas técnicas', eventId),
        const SizedBox(height: 20),
      ],
    );
  }

  // MODAL SALIDA (Con tus 4 opciones para cambiar + acciones finales)
  Widget _buildExitSessionModal(BuildContext context, String eventId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gestionar Turno', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Puedes cambiar tu actividad actual o finalizar el turno.', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        const SizedBox(height: 20),
        const Text('CAMBIAR ACTIVIDAD', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        _buildActionOption(context, Icons.business, 'Oficina', 'Reuniones / Administrativo', eventId),
        const SizedBox(height: 10),
        _buildActionOption(context, Icons.build, 'Taller', 'Reparaciones', eventId),
        const SizedBox(height: 10),
        _buildActionOption(context, Icons.local_shipping, 'Transporte', 'Traslados', eventId),
        const SizedBox(height: 10),
        _buildActionOption(context, Icons.construction, 'Servicio', 'Visitas técnicas', eventId),
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
                  _endSessionLocal(eventId);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salida registrada'), backgroundColor: Colors.red));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildActionOption(BuildContext context, IconData icon, String title, String subtitle, String eventId) {
    return GestureDetector(
      onTap: () {
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