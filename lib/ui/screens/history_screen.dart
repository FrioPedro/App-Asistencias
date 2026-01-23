import 'package:flutter/material.dart';

// --- IMPORTS ACTUALIZADOS ---
import '../../models/activity_model.dart';       // Usamos ActivityModel para el historial
import '../../providers/history_provider.dart';  // Provider actualizado
import '../widgets/event_card.dart';
import '../widgets/event_card_skeleton.dart';

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
  DateTimeRange? _selectedDateRange;
  
  // Lista de nuevos modelos
  List<ActivityModel> _allEvents = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    
    // Carga inicial
    _loadData();
  }

  /// Pide los datos al Provider
  Future<void> _loadData() async {
    final loadedEvents = await _historyService.fetchHistory();
    if (mounted) {
      setState(() {
        _allEvents = loadedEvents;
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

  // Helper para formatear fecha (DateTime -> String)
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    
    final datePart = isToday ? 'Hoy' : '${date.day}/${date.month}/${date.year}';
    return '$datePart, $hour:$minute $amPm';
  }

  // --- LÓGICA DE FILTRADO (Adaptada a AssigmentModel) ---
  
  List<ActivityModel> _getFilteredEvents() {
    return _allEvents.where((event) {
      // 1. Filtro de Texto (Usamos propiedades nuevas con Null Check)
      final desc = (event.description ?? '').toLowerCase();
      final client = (event.client ?? '').toLowerCase();
      final docId = (event.documentId ?? '').toLowerCase();

      final matchesText = _searchQuery.isEmpty || 
          desc.contains(_searchQuery) ||
          client.contains(_searchQuery) ||
          docId.contains(_searchQuery);

      if (!matchesText) return false;

      // 2. Filtro de Fechas
      if (_selectedDateRange != null) {
        // Usamos directamente event.timestamp que ya es DateTime
        final eventDate = event.timestamp;
        
        final start = _selectedDateRange!.start.subtract(const Duration(seconds: 1));
        final end = _selectedDateRange!.end.add(const Duration(days: 1));
        
        final matchesDate = eventDate.isAfter(start) && eventDate.isBefore(end);
        if (!matchesDate) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      saveText: 'FILTRAR',
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: const Color(0xFF4CAF50),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
              secondary: Color(0xFF4CAF50),
            ), 
            //dialogTheme: const DialogTheme(backgroundColor: Color(0xFF1E1E1E)),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _getFilteredEvents();
    final isDateFilterActive = _selectedDateRange != null;

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
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BUSCADOR Y CALENDARIO ---
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        hintText: 'Buscar evento...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey[600]),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDateFilterActive ? const Color(0xFF4CAF50) : const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isDateFilterActive ? Icons.event_available : Icons.date_range,
                        color: Colors.white,
                      ),
                      onPressed: _pickDateRange,
                    ),
                  ),
                ],
              ),

              // --- CHIP FILTRO ---
              if (isDateFilterActive)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Filtrando: ${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                          style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _selectedDateRange = null),
                          child: const Icon(Icons.close, color: Color(0xFF4CAF50), size: 18),
                        )
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              
              // --- LISTA ---
              Expanded(
                child: _isLoading 
                    ? _buildSkeletons() 
                    : filteredEvents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_toggle_off, size: 60, color: Colors.grey[800]),
                                const SizedBox(height: 16),
                                Text('No se encontraron eventos', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          )
                        : ListView(
                            children: filteredEvents.map((event) => EventCard(
                                  // Mapeo de campos nuevos
                                  eventName: event.description ?? 'Sin descripción',
                                  companyName: event.client ?? 'Sin cliente',
                                  eventCode: event.documentId ?? '---',
                                  dateTime: _formatDate(event.timestamp), // Formato de fecha
                                  
                                  // Nuevo Enum
                                  assigmentType: event.activityType,
                                  
                                  isParticipating: false, // Histórico estático
                                  onTap: null, 
                                  
                                  hasPendingSync: !event.isSynced,
                                )).toList(),
                          ),
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
      itemBuilder: (context, index) {
        return const EventCardSkeleton();
      },
    );
  }
}