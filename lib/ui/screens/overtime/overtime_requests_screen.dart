import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';

import 'package:app_asistencias/models/overtime_request_model.dart';
import 'package:app_asistencias/providers/overtime_provider.dart';
import 'package:app_asistencias/ui/screens/overtime/overtime_detail_sheet.dart';
import 'package:app_asistencias/ui/screens/overtime/overtime_format.dart';
import 'package:app_asistencias/ui/screens/overtime/overtime_approval_status_style.dart';

/// Pantalla de consulta de solicitudes de horas extras. Es solo lectura: la
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

  static const int _pageSize = 20;

  OvertimeRequestGroups _groups = const OvertimeRequestGroups();
  bool _isLoading = true;

  OvertimeStatus _tab = OvertimeStatus.pending;
  int _visibleCount = _pageSize;

  final ScrollController _tabsScroll = ScrollController();
  bool _tabsFadeLeft = false;
  bool _tabsFadeRight = false;

  void _syncTabsFade() {
    if (!_tabsScroll.hasClients) return;

    final position = _tabsScroll.position;
    final left = position.pixels > 1;
    final right = position.pixels < position.maxScrollExtent - 1;

    if (left == _tabsFadeLeft && right == _tabsFadeRight) return;

    setState(() {
      _tabsFadeLeft = left;
      _tabsFadeRight = right;
    });
  }

  List<OvertimeRequestModel> _requestsFor(OvertimeStatus status) {
    switch (status) {
      case OvertimeStatus.pending:
        return _visibleGroups.pending;
      case OvertimeStatus.approved:
        return _visibleGroups.approved;
      case OvertimeStatus.rejected:
        return _visibleGroups.rejected;
    }
  }

  void _selectTab(OvertimeStatus status) {
    if (status == _tab) return;

    setState(() {
      _tab = status;
      _visibleCount = _pageSize;
    });
  }

  OvertimeRequestGroups get _visibleGroups => _showMockRequest
      ? OvertimeRequestGroups(
          approved: _groups.approved,
          pending: [..._mockRequests(), ..._groups.pending],
          rejected: _groups.rejected,
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
    _tabsScroll.addListener(_syncTabsFade);
    _bootstrap();
  }

  @override
  void dispose() {
    _tabsScroll.dispose();
    super.dispose();
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

    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTabsFade());
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
        title: const Text('Aprobaciones de horas extras'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildTabs(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      color: Colors.white,
                      backgroundColor: AppColors.surface,
                      child: _requestsFor(_tab).isEmpty
                          ? _buildEmptyTab()
                          : _buildList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTabs() {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _tabsScroll,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.sm,
            AppSpacing.gutter,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              for (final status in OvertimeStatus.values) ...[
                _buildTab(status, _requestsFor(status).length),
                if (status != OvertimeStatus.values.last)
                  const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
        ),
        if (_tabsFadeLeft) _buildTabsFade(left: true),
        if (_tabsFadeRight) _buildTabsFade(left: false),
      ],
    );
  }

  /// Insinua que la fila sigue: se desvanece hacia el fondo de la pantalla.
  Widget _buildTabsFade({required bool left}) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: IgnorePointer(
        child: Container(
          width: AppSpacing.xxl,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: left ? Alignment.centerLeft : Alignment.centerRight,
              end: left ? Alignment.centerRight : Alignment.centerLeft,
              colors: [AppColors.bg, AppColors.bg.withOpacity(0)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(OvertimeStatus status, int count) {
    final selected = status == _tab;

    return ChoiceChip(
      selected: selected,
      onSelected: (_) => _selectTab(status),
      label: Text('${OvertimeFormat.tabLabels(status)} ($count)'),
      labelStyle: TextStyle(
        color: selected ? AppColors.onAccent : AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Colors.transparent,
      selectedColor: status.color,
      showCheckmark: false,
      side: BorderSide.none,
      shape: const StadiumBorder(),
    );
  }

  Widget _buildList() {
    final all = _requestsFor(_tab);
    final shown = all.take(_visibleCount).toList();
    final remaining = all.length - shown.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: [
        for (final request in shown) ...[
          _OvertimeRequestCard(
            request: request,
            projectName: _visibleGroups.projectName(request),
            projectCode: _visibleGroups.projectCode(request),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (remaining > 0) _buildLoadMore(remaining),
      ],
    );
  }

  Widget _buildLoadMore(int remaining) {
    return OutlinedButton(
      onPressed: () => setState(() => _visibleCount += _pageSize),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textMeta,
        minimumSize: const Size.fromHeight(AppSpacing.ctaHeight),
        side: const BorderSide(color: AppColors.border),
        shape: const StadiumBorder(),
      ),
      child: Text(
        'Cargar más ($remaining)',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyTab() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.assignment,
                      size: 64, color: AppColors.iconMuted),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'No tiene solicitudes '
                    '${OvertimeFormat.tabLabels(_tab).toLowerCase()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Puede enviar justificaciones desde la asignación.',
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

  const _OvertimeRequestCard({
    required this.request,
    required this.projectName,
    required this.projectCode,
  });

  static const double _statusIconSize = 20;

  /// Las filas de detalle cuelgan del texto del titulo, no del borde: el
  /// sangrado es el ancho del icono de estado mas su separacion.
  static const double _contentIndent = _statusIconSize + AppSpacing.sm;

  Color get _statusColor => request.status.color;

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
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(context),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(left: _contentIndent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProject(),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Horas justificadas: '
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

  /// Cuando se resolvio la solicitud. Vacio en las pendientes: todavia no hay
  /// nada que fechar.
  String get _resolvedAgo => request.status == OvertimeStatus.pending
      ? ''
      : OvertimeFormat.submittedAgo(request.resolvedAt);

  /// Icono de estado, codigo de proyecto y rango de fechas, con el "hace X" de
  /// la resolucion a la derecha.
  Widget _buildTitle(BuildContext context) {
    final header = _buildHeaderLine();

    if (_resolvedAgo.isEmpty) return header;

    // 20 px es donde el rango de fechas y el "hace X" dejan de caber juntos.
    if (MediaQuery.textScalerOf(context).scale(15) > 20) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(left: _contentIndent),
            child: _buildResolvedAgo(),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: header),
        const SizedBox(width: AppSpacing.sm),
        _buildResolvedAgo(),
      ],
    );
  }

  Widget _buildResolvedAgo() {
    return Text(
      _resolvedAgo,
      style: TextStyle(
        color: _statusColor,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildHeaderLine() {
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
