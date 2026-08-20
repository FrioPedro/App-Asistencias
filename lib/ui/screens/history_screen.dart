import 'package:app_asistencias/models/taskType_model.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

// --- IMPORTS ACTUALIZADOS ---
// import '../../models/activity/activity_model.dart';
// import '../../models/assigment_model.dart';
import '../../providers/history_provider.dart';
import '../widgets/event_card_history.dart';
import '../widgets/event_card_skeleton.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/calendar_modal.dart';
import '../../domain/activity/get_activity.dart';
import '../../providers/log_provider.dart';
import '../../models/log_model.dart';
import 'package:intl/intl.dart';

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
  DateTime? _selectedDate;

  // Lista de modelos (Sesiones unificadas)
  List<ActivitySession> _allActivities = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _selectedDate = null;
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
      isDismissible: false,
      enableDrag: false,
      builder: (context) => CalendarModal(
        initialDate: _selectedDate ?? DateTime.now(),
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });
          LogProvider.log(
            'Histórico: Filtrado por fecha ${DateFormat('dd/MM/yyyy').format(date)}',
            type: LogType.info,
            origin: 'HistoryScreen',
          );
        },
      ),
    );
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
    LogProvider.log(
      'Histórico: Filtro de fecha limpiado',
      type: LogType.info,
      origin: 'HistoryScreen',
    );
  }

  void _showDebugInfo() async {
    final data = await GetActivity.getLocalData(); // Raw from Isar
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Debug Raw (${data.length} items)'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (ctx, i) {
              final a = data[i];
              return ListTile(
                dense: true,
                title: Text('Token: ${a.keyGroup}...'),
                subtitle: Text(
                    'ID:${a.assigmentId} Task:${a.task.name} Open:${a.motiveActivity}'),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- LÓGICA DE FILTRADO ---
  List<ActivitySession> _getFilteredSessions() {
    // Las actividades ya vienen ordenadas por GetActivity (reciente primero)
    // Simplemente filtramos.

    return _allActivities.where((session) {
      // 1. Filtro de Texto
      final desc = (session.description ?? '').toLowerCase();
      final client = (session.client ?? '').toLowerCase();
      final docId = (session.documentId ?? '').toLowerCase();

      final matchesText = _searchQuery.isEmpty ||
          desc.contains(_searchQuery) ||
          client.contains(_searchQuery) ||
          docId.contains(_searchQuery);

      if (!matchesText) return false;

      // 2. Filtro de Fecha (DÍA ÚNICO)
      if (_selectedDate != null) {
        final activityDate = session.entryTimestamp; // Usamos fecha de entrada

        final isSameDay = activityDate.year == _selectedDate!.year &&
            activityDate.month == _selectedDate!.month &&
            activityDate.day == _selectedDate!.day;

        if (!isSameDay) return false;
      }

      return true;
    }).toList();
  }

  String _formatTime(DateTime d) {
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final amPm = d.hour >= 12 ? 'PM' : 'AM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '$hour:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final filteredSessions = _getFilteredSessions();
    final isDateFilterActive = _selectedDate != null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onLongPress: _showDebugInfo,
          child: const Text('Histórico'),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BUSCADOR Y BOTÓN CALENDARIO ---
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.sm),
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
                  // Botón Calendario
                  Container(
                    decoration: BoxDecoration(
                      color: isDateFilterActive
                          ? AppColors.success
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
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

            // --- CHIP FILTRO ---
            if (isDateFilterActive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sheet),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Filtrando: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: const TextStyle(
                                color: AppColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _clearDateFilter,
                            child: const Icon(Icons.close,
                                color: AppColors.success, size: 18),
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
                      color: AppColors.primary,
                      backgroundColor: AppColors.surface,
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
                                        const Icon(Icons.event_busy,
                                            size: 60, color: AppColors.iconMuted),
                                        const SizedBox(height: 16),
                                        Text(
                                            isDateFilterActive
                                                ? 'No hay actividades para esta fecha'
                                                : 'No se encontraron actividades',
                                            style: const TextStyle(
                                                color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                              itemCount: filteredSessions.length,
                              itemBuilder: (context, index) {
                                final session = filteredSessions[index];

                                return EventCard(
                                  eventName:
                                      session.description ?? 'Sin descripción',
                                  companyName: session.client ?? 'Sin cliente',
                                  eventCode: session.documentId ?? '---',
                                  taskName: session.task.label,

                                  // Mapeo de tiempos unificado
                                  entryTime:
                                      _formatTime(session.entryTimestamp),
                                  exitTime: session.exitTimestamp != null
                                      ? _formatTime(session.exitTimestamp!)
                                      : null,

                                  hasPendingSync: session.hasPendingSync,
                                  assigmentType: session.activityType,
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
