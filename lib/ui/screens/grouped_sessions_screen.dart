// ============================================================================
// GroupedSessionsScreen - Pantalla de sesiones agrupadas por keyGroup
// ============================================================================
// Muestra las asistencias agrupadas con estadísticas diarias/semanales
// y permite visualizar el detalle de cada sesión agrupada.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:app_asistencias/domain/keygroup/keygroup.dart';
import 'package:app_asistencias/providers/keygroup_stats_provider.dart';
import 'package:app_asistencias/providers/history_provider.dart';
import 'package:app_asistencias/ui/widgets/session_group_card.dart';
import 'package:app_asistencias/providers/log_provider.dart';
import 'package:app_asistencias/models/log_model.dart';
import 'package:intl/intl.dart';

class GroupedSessionsScreen extends StatefulWidget {
  const GroupedSessionsScreen({super.key});

  @override
  State<GroupedSessionsScreen> createState() => _GroupedSessionsScreenState();
}

class _GroupedSessionsScreenState extends State<GroupedSessionsScreen>
    with SingleTickerProviderStateMixin {
  final KeyGroupStatsProvider _statsProvider = KeyGroupStatsProvider();
  final KeyGroupService _service = KeyGroupService();

  late TabController _tabController;

  bool _isLoading = true;
  DailyStats? _todayStats;
  WeeklyStats? _weekStats;
  List<ActivitySession> _todaySessions = [];
  List<ActivitySession> _weekSessions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    LogProvider.log(
      'Pantalla de sesiones agrupadas abierta',
      type: LogType.info,
      origin: 'GroupedSessionsScreen',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final todayStats = await _statsProvider.getTodayStats();
      final weekStats = await _statsProvider.getCurrentWeekStats();
      final todaySessions = await _service.getSessionsByDay(DateTime.now());
      final weekData = await _service.getCurrentWeekSessions();

      if (mounted) {
        setState(() {
          _todayStats = todayStats;
          _weekStats = weekStats;
          _todaySessions = todaySessions;
          _weekSessions = weekData.sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      LogProvider.log(
        'Error cargando datos: $e',
        type: LogType.error,
        origin: 'GroupedSessionsScreen',
      );
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Sesiones Agrupadas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF2E60C4),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Hoy'),
            Tab(text: 'Esta Semana'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E60C4),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF2E60C4),
              backgroundColor: const Color(0xFF2C2C2C),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTodayTab(),
                  _buildWeekTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildTodayTab() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Tarjeta de estadísticas de hoy
        SliverToBoxAdapter(
          child: _buildTodayStatsCard(),
        ),

        // Título de sesiones
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Text(
              'Sesiones de Hoy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Lista de sesiones de hoy
        _todaySessions.isEmpty
            ? SliverToBoxAdapter(
                child: _buildEmptyState('No hay sesiones hoy'),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final session = _todaySessions[index];
                      return SessionGroupCard(
                        session: session,
                        showKeyGroup: true,
                        onTap: () => _showSessionDetail(session),
                      );
                    },
                    childCount: _todaySessions.length,
                  ),
                ),
              ),

        // Espaciado final
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildWeekTab() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Tarjeta de estadísticas semanales
        SliverToBoxAdapter(
          child: _buildWeekStatsCard(),
        ),

        // Título de sesiones
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Text(
              'Sesiones de la Semana',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Lista de sesiones de la semana
        _weekSessions.isEmpty
            ? SliverToBoxAdapter(
                child: _buildEmptyState('No hay sesiones esta semana'),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final session = _weekSessions[index];
                      return SessionGroupCard(
                        session: session,
                        compactMode: true,
                        onTap: () => _showSessionDetail(session),
                      );
                    },
                    childCount: _weekSessions.length,
                  ),
                ),
              ),

        // Espaciado final
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildTodayStatsCard() {
    if (_todayStats == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E60C4), Color(0xFF1E4A9C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E60C4).withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM', 'es').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Resumen del Día',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.timer_outlined,
                value: _todayStats!.formattedTotalTime,
                label: 'Trabajado',
              ),
              _buildStatDivider(),
              _buildStatItem(
                icon: Icons.check_circle_outline,
                value: '${_todayStats!.completedSessions}',
                label: 'Completadas',
              ),
              _buildStatDivider(),
              _buildStatItem(
                icon: Icons.pending_actions,
                value: '${_todayStats!.ongoingSessions}',
                label: 'En Curso',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStatsCard() {
    if (_weekStats == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.date_range_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('d MMM', 'es').format(_weekStats!.weekStart)} - ${DateFormat('d MMM', 'es').format(_weekStats!.weekEnd)}',
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Resumen Semanal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.timer_outlined,
                value: _weekStats!.formattedTotalTime,
                label: 'Total',
              ),
              _buildStatDivider(),
              _buildStatItem(
                icon: Icons.layers_outlined,
                value: '${_weekStats!.totalSessions}',
                label: 'Sesiones',
              ),
              _buildStatDivider(),
              _buildStatItem(
                icon: Icons.star_outline,
                value: _weekStats!.busiestDayName,
                label: 'Día Activo',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(179),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.white.withAlpha(51),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionDetail(ActivitySession session) {
    LogProvider.log(
      'Ver detalle de sesión: ${session.keyGroup}',
      type: LogType.info,
      origin: 'GroupedSessionsScreen',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SessionDetailSheet(session: session),
    );
  }
}

// ============================================================================
// Widget de detalle de sesión
// ============================================================================
class _SessionDetailSheet extends StatelessWidget {
  final ActivitySession session;

  const _SessionDetailSheet({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E60C4).withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    color: Color(0xFF2E60C4),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.description ?? 'Sin descripción',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.client ?? 'Sin cliente',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: Colors.grey[800],
          ),

          // Detalles
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.key_rounded,
                  'ID de Grupo',
                  session.keyGroup,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.document_scanner_outlined,
                  'Documento',
                  session.documentId ?? 'N/A',
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.login_rounded,
                  'Entrada',
                  DateFormat('dd/MM/yyyy HH:mm').format(session.entryTimestamp),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.logout_rounded,
                  'Salida',
                  session.exitTimestamp != null
                      ? DateFormat('dd/MM/yyyy HH:mm')
                          .format(session.exitTimestamp!)
                      : 'En curso',
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.sync_rounded,
                  'Estado de Sync',
                  session.hasPendingSync ? 'Pendiente' : 'Sincronizado',
                ),
              ],
            ),
          ),

          // Botón cerrar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E60C4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey[400], size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
