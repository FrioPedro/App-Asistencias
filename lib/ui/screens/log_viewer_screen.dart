import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/log_model.dart';
import '../../providers/log_provider.dart';
import '../widgets/custom_search_bar.dart';
import 'sheets/log_filter_sheet.dart';

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  final LogProvider _logProvider = LogProvider();

  List<LogModel> _allLogs = [];
  List<LogModel> _filteredLogs = [];
  bool _isLoading = true;
  DateTimeRange? _selectedDateRange;
  List<LogType> _selectedTypes = [];
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    final logs = await _logProvider.fetchLogs();
    if (mounted) {
      setState(() {
        _allLogs = logs;
        _filteredLogs = logs;
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredLogs = _allLogs.where((log) {
        // Filtro de Texto
        final matchesSearch = _searchQuery.isEmpty ||
            log.message.toLowerCase().contains(_searchQuery.toLowerCase());

        // Filtro de Fecha
        bool matchesDate = true;
        if (_selectedDateRange != null) {
          final start =
              _selectedDateRange!.start.subtract(const Duration(seconds: 1));
          final end = _selectedDateRange!.end.add(const Duration(days: 1));
          matchesDate =
              log.timestamp.isAfter(start) && log.timestamp.isBefore(end);
        }

        // Filtro de Tipo
        bool matchesType = true;
        if (_selectedTypes.isNotEmpty) {
          matchesType = _selectedTypes.contains(log.type);
        }

        return matchesSearch && matchesDate && matchesType;
      }).toList();
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => LogFilterSheet(
        initialDateRange: _selectedDateRange,
        initialTypes: _selectedTypes,
        onApply: (range, types) {
          setState(() {
            _selectedDateRange = range;
            _selectedTypes = types;
          });
          _applyFilter();
        },
      ),
    );
  }

  IconData _getIconByType(LogType type) {
    switch (type) {
      case LogType.error:
        return Icons.bug_report_rounded; // O Icons.dangerous_rounded
      case LogType.warning:
        return Icons.warning_amber_rounded; // O Icons.bolt_rounded
      case LogType.info:
        return Icons.info_rounded; // O Icons.article_rounded
    }
  }

  String _getTypeLabel(LogType type) {
    switch (type) {
      case LogType.error:
        return 'ERR';
      case LogType.warning:
        return 'ADV';
      case LogType.info:
        return 'INF';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final isToday = timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;

    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    final amPm = timestamp.hour >= 12 ? 'PM' : 'AM';
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');

    if (isToday) {
      return 'Hoy, $hour:$minute:$second $amPm';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}, $hour:$minute:$second $amPm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
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
              // Header
              _buildHeader(context),
              const SizedBox(height: 16),

              // Buscador
              CustomSearchBar(
                controller: _searchController,
                hintText: 'Buscar en logs',
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                  _applyFilter();
                },
              ),
              const SizedBox(height: 16),

              // Chips de filtros activos
              if (_selectedDateRange != null || _selectedTypes.isNotEmpty) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (_selectedDateRange != null) _buildFilterChip('Fecha'),
                      if (_selectedTypes.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _buildFilterChip('Tipo (${_selectedTypes.length})'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Lista de logs
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _filteredLogs.isEmpty
                        ? _buildEmptyState()
                        : _buildLogsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            'Logs del Sistema',
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
              (_selectedDateRange != null || _selectedTypes.isNotEmpty)
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
              () => _openFilterSheet(),
              isActive: _selectedDateRange != null || _selectedTypes.isNotEmpty,
            ),
            const SizedBox(width: 12),
            _buildHeaderButton(
              Icons.arrow_back,
              () => Navigator.pop(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap,
      {bool isActive = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4CAF50) : const Color(0xFF2C2C2C),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2E60C4).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E60C4).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Color(0xFF2E60C4),
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (label == 'Fecha') {
                setState(() => _selectedDateRange = null);
              } else {
                setState(() => _selectedTypes = []);
              }
              _applyFilter();
            },
            child: const Icon(Icons.close, color: Color(0xFF2E60C4), size: 18),
          )
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF4CAF50),
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 60, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(
            'No se encontraron logs',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    return ListView.builder(
      itemCount: _filteredLogs.length,
      itemBuilder: (context, index) {
        final log = _filteredLogs[index];
        return _buildLogCard(log);
      },
    );
  }

  Widget _buildLogCard(LogModel log) {
    final color = _logProvider.getColorByType(log.type);
    final icon = _getIconByType(log.type);
    final typeLabel = _getTypeLabel(log.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Stack(
        children: [
          // Icono de fondo difuminado
          Positioned(
            right: -20,
            top: -10,
            bottom: -10,
            child: SizedBox(
              width: 120,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black,
                    ],
                    stops: [0.0, 0.3, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Stack(
                  children: [
                    // Versión borrosa
                    Center(
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                        child: Icon(
                          icon,
                          size: 80,
                          color: color.withOpacity(0.4),
                        ),
                      ),
                    ),
                    // Versión nítida
                    Center(
                      child: Icon(
                        icon,
                        size: 80,
                        color: color.withOpacity(0.25),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila superior: Tipo y Timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge de tipo
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 12, color: color),
                          const SizedBox(width: 2),
                          Text(
                            typeLabel,
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Timestamp
                    Text(
                      _formatTimestamp(log.timestamp),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Mensaje
                Text(
                  log.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
