import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';

import 'package:app_asistencias/models/overtime_request_model.dart';
import 'package:app_asistencias/providers/overtime_provider.dart';
import 'package:app_asistencias/ui/screens/overtime/overtime_format.dart';

/// Pantalla de consulta de solicitudes de horas extra. Es solo lectura: la
/// creación vive en el turno activo ([AssigmentModal]).
class OvertimeRequestsScreen extends StatefulWidget {
  const OvertimeRequestsScreen({super.key});

  @override
  State<OvertimeRequestsScreen> createState() => _OvertimeRequestsScreenState();
}

class _OvertimeRequestsScreenState extends State<OvertimeRequestsScreen> {
  final OvertimeProvider _overtime = OvertimeProvider();

  /// Mientras el backend no devuelve solicitudes, se muestra una de ejemplo
  /// para revisar el diseno de la tarjeta. Poner en false al conectar la API.
  static const bool _showMockRequest = false; // usar para debuggear

  List<OvertimeRequestModel> _requests = [];
  bool _isLoading = true;

  List<OvertimeRequestModel> get _visibleRequests =>
      _showMockRequest ? [..._mockRequests(), ..._requests] : _requests;

  List<OvertimeRequestModel> _mockRequests() {
    final day = OvertimeRequestModel.dateOnly(DateTime.now())
        .add(const Duration(days: 2));

    return [
      OvertimeRequestModel.create(
        projectId: 0,
        start: day.add(const Duration(hours: 18)),
        end: day.add(const Duration(hours: 22)),
        justification:
            'Se debe terminar el lote de empaque pendiente del turno de dia.',
        submittedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// Muestra primero lo que hay en local y despues consulta al servidor, para
  /// no dejar la pantalla en blanco mientras responden los proyectos.
  Future<void> _bootstrap() async {
    await _load();
    await _overtime.syncNow();
    await _load();
  }

  Future<void> _load() async {
    final requests = await _overtime.fetchLocalRequests();
    if (!mounted) return;
    setState(() {
      _requests = requests;
      _isLoading = false;
    });
  }

  /// Pull-to-refresh.
  Future<void> _refresh() async {
    await _overtime.syncNow();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mis solicitudes'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.white,
          backgroundColor: AppColors.surface,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _visibleRequests.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.gutter,
                        AppSpacing.sm,
                        AppSpacing.gutter,
                        AppSpacing.xl,
                      ),
                      itemCount: _visibleRequests.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) => _OvertimeRequestCard(
                        request: _visibleRequests[index],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hourglass_empty,
                      size: 64, color: AppColors.iconMuted),
                  SizedBox(height: AppSpacing.xl),
                  Text(
                    'Todavía no ha solicitado\nhoras extra',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Pide horas extra desde la asignación.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de una solicitud.
class _OvertimeRequestCard extends StatelessWidget {
  final OvertimeRequestModel request;

  const _OvertimeRequestCard({required this.request});

  Color get _statusColor {
    switch (request.status) {
      case OvertimeStatus.approved:
        return AppColors.success;
      case OvertimeStatus.rejected:
        return AppColors.danger;
      case OvertimeStatus.pending:
        return AppColors.warning;
    }
  }

  IconData get _statusIcon {
    switch (request.status) {
      case OvertimeStatus.approved:
        return Icons.check_circle;
      case OvertimeStatus.rejected:
        return Icons.cancel;
      case OvertimeStatus.pending:
        return Icons.hourglass_top;
    }
  }

  String get _statusLabel {
    switch (request.status) {
      case OvertimeStatus.approved:
        return 'APROBADA';
      case OvertimeStatus.rejected:
        return 'RECHAZADA';
      case OvertimeStatus.pending:
        return 'PENDIENTE';
    }
  }

  /// El servidor no devuelve quién resolvió ni por qué: una solicitud ya
  /// resuelta se queda solo con su estado.
  String get _footer => request.status == OvertimeStatus.pending
      ? 'Esperando a su supervisor'
      : '';

  @override
  Widget build(BuildContext context) {
    final submittedAgo = OvertimeFormat.submittedAgo(request.submittedAt);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _statusColor.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_statusIcon, color: _statusColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (submittedAgo.isNotEmpty)
                Text(
                  submittedAgo,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            OvertimeFormat.dateRange(request),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${OvertimeFormat.timeRange(request)}  ·  '
            '${OvertimeFormat.duration(request.duration)}',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          if (_footer.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _footer,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
