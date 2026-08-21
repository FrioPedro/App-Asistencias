import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';

import 'package:app_asistencias/models/overtime_request_model.dart';
import 'package:app_asistencias/providers/overtime_provider.dart';
import 'package:app_asistencias/ui/screens/overtime/overtime_detail_sheet.dart';
import 'package:app_asistencias/ui/screens/overtime/overtime_format.dart';
import 'package:app_asistencias/ui/screens/overtime/overtime_status_style.dart';

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

  OvertimeRequestGroups _groups = const OvertimeRequestGroups();
  bool _isLoading = true;
  bool _showPasadas = false;

  OvertimeRequestGroups get _visibleGroups => _showMockRequest
      ? OvertimeRequestGroups(
          approved: _groups.approved,
          pending: [..._mockRequests(), ..._groups.pending],
          rejected: _groups.rejected,
          pasadas: _groups.pasadas,
        )
      : _groups;

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
    final groups = await _overtime.fetchLocalRequests();
    if (!mounted) return;
    setState(() {
      _groups = groups;
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
        title: const Text('Solicitudes de horas extra'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.white,
          backgroundColor: AppColors.surface,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _visibleGroups.isEmpty
                  ? _buildEmptyState()
                  : _buildSections(),
        ),
      ),
    );
  }

  Widget _buildSections() {
    final groups = _visibleGroups;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: [
        ..._section('Aprobadas', groups.approved),
        ..._section('Pendientes', groups.pending),
        ..._section('Rechazadas', groups.rejected),
        ..._pasadasSection(groups.pasadas),
      ],
    );
  }

  List<Widget> _section(String title, List<OvertimeRequestModel> requests) {
    if (requests.isEmpty) return const [];

    return [
      _SectionHeader(title: title, count: requests.length),
      for (final request in requests) ...[
        _OvertimeRequestCard(
          request: request,
          projectName: _visibleGroups.projectName(request),
          projectCode: _visibleGroups.projectCode(request),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    ];
  }

  /// Las pasadas ya no son accionables, asi que arrancan colapsadas.
  List<Widget> _pasadasSection(List<OvertimeRequestModel> requests) {
    if (requests.isEmpty) return const [];

    return [
      _SectionHeader(title: 'Pasadas', count: requests.length),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => setState(() => _showPasadas = !_showPasadas),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: Icon(
            _showPasadas ? Icons.expand_less : Icons.expand_more,
            size: 18,
          ),
          label: Text(
            _showPasadas ? 'Ocultar' : 'Mostrar',
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      if (_showPasadas)
        for (final request in requests) ...[
          _OvertimeRequestCard(
            request: request,
            projectName: _visibleGroups.projectName(request),
            projectCode: _visibleGroups.projectCode(request),
            isPast: true,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
    ];
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
                  Icon(Icons.assignment, size: 64, color: AppColors.iconMuted),
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

/// Tarjeta de una solicitud: codigo, rango de fechas, proyecto y horas. El
/// detalle completo vive en [OvertimeDetailSheet].
class _OvertimeRequestCard extends StatelessWidget {
  final OvertimeRequestModel request;
  final String projectName;
  final String projectCode;

  /// Las solicitudes que ya empezaron se dibujan con el icono de estado
  /// apagado: el estado sigue siendo informativo pero ya no es accionable.
  final bool isPast;

  const _OvertimeRequestCard({
    required this.request,
    required this.projectName,
    required this.projectCode,
    this.isPast = false,
  });

  static const double _statusIconSize = 20;

  /// Las filas de detalle cuelgan del texto del titulo, no del borde: el
  /// sangrado es el ancho del icono de estado mas su separacion.
  static const double _contentIndent = _statusIconSize + AppSpacing.sm;

  Color get _statusColor => isPast ? AppColors.iconMuted : request.status.color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: _statusColor.withOpacity(0.35)),
      ),
      child: InkWell(
        onTap: () => OvertimeDetailSheet.show(
          context,
          request: request,
          projectCode: projectCode,
          isPast: isPast,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(left: _contentIndent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProject(),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Horas solicitadas: '
                      '${OvertimeFormat.duration(request.duration)}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Icono de estado, codigo de proyecto y rango de fechas.
  Widget _buildTitle() {
    return Row(
      children: [
        Icon(request.status.icon, color: _statusColor, size: _statusIconSize),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                if (projectCode.isNotEmpty)
                  TextSpan(
                    text: '$projectCode   ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                TextSpan(
                  text: OvertimeFormat.dateRange(request),
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProject() {
    return Row(
      children: [
        const Icon(Icons.work_outline, size: 15, color: AppColors.iconMuted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            projectName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppColors.textMeta,
                fontWeight: FontWeight.w500,
                fontSize: 13),
          ),
        ),
      ],
    );
  }
}

/// Titulo gris de cada seccion de la lista.
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            '$title ($count)',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(child: Divider(color: AppColors.border, height: 1)),
        ],
      ),
    );
  }
}
