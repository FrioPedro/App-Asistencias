import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';

import 'package:app_asistencias/models/overtime_request_model.dart';
import 'package:app_asistencias/ui/screens/overtime/overtime_format.dart';
import 'package:app_asistencias/ui/screens/overtime/overtime_status_style.dart';

/// Detalle de una solicitud de horas extra, abierto al tocar su tarjeta en
/// [OvertimeRequestsScreen]. Es solo lectura: el operario no puede editar ni
/// cancelar desde aca.
class OvertimeDetailSheet extends StatelessWidget {
  final OvertimeRequestModel request;
  final String projectCode;

  /// Una solicitud que ya empezo pinta el marco en gris: sigue mostrando su
  /// estado, pero ya no hay nada que resolver.
  final bool isPast;

  const OvertimeDetailSheet({
    super.key,
    required this.request,
    required this.projectCode,
    this.isPast = false,
  });

  static void show(
    BuildContext context, {
    required OvertimeRequestModel request,
    required String projectCode,
    bool isPast = false,
  }) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => OvertimeDetailSheet(
        request: request,
        projectCode: projectCode,
        isPast: isPast,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.sm),
              _buildStatusPanel(),
              const SizedBox(height: AppSpacing.md),
              _buildDataPanel(context),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solicitud de horas extra',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (projectCode.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    projectCode,
                    style: const TextStyle(
                      color: AppColors.textMeta,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close,
                color: AppColors.textSecondary, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Estado, timestamp y sustento
  Widget _buildStatusPanel() {
    return _panel([
      _statusLine(),
      if (request.status != OvertimeStatus.pending &&
          _reviewerMessage.isNotEmpty)
        _block('Sustento', _reviewerMessage),
    ]);
  }

  /// Datos de la solicitud
  Widget _buildDataPanel(BuildContext context) {
    final useCompactText = MediaQuery.textScalerOf(context).scale(16) > 26;
    return _panel([
      _row('Inicio', _dateTime(request.start),
          previousValue: request.previousStart),
      _row('Fin', _dateTime(request.end), previousValue: request.previousEnd),
      _row('Duración', OvertimeFormat.duration(request.duration)),
      if (_submittedOn.isNotEmpty)
        _row(useCompactText ? 'Solicitado' : 'Solicitud enviada', _submittedOn),
      _block('Justificación', request.justification),
    ]);
  }

  Widget _panel(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceTable,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  String _dateTime(DateTime d) =>
      '${OvertimeFormat.dayMonth(d)}, ${OvertimeFormat.timeOf(d)}';

  String get _submittedOn => OvertimeFormat.submittedAgo(request.submittedAt);

  String get _reviewerMessage => request.sustenance ?? '';

  Widget _row(
    String label,
    String value, {
    DateTime? previousValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (previousValue != null) ...[
                  Flexible(
                    child: Text(
                      _dateTime(previousValue),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.iconMuted,
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.iconMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusLine() {
    final label = OvertimeFormat.statusLabel(request.status);
    final approver = OvertimeFormat.approverLine(request);
    final statusChangeTimestamp = request.resolvedAt != null
        ? 'el ${OvertimeFormat.submittedOn(request.resolvedAt)}'
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SizedBox(
        width: double.infinity,
        child: Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Icon(request.status.icon,
                      color: request.status.color, size: 16),
                ),
              ),
              TextSpan(
                text: approver.isEmpty
                    ? '$label $statusChangeTimestamp'
                    : '$label $approver $statusChangeTimestamp',
              ),
            ],
          ),
          style: TextStyle(
            color: request.status.color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _block(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                color: value.isEmpty ? AppColors.textSecondary : Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
