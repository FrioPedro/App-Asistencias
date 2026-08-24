import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';

import 'package:app_asistencias/models/log_model.dart';
import 'package:app_asistencias/models/overtime_request_model.dart';
import 'package:app_asistencias/providers/log_provider.dart';
import 'package:app_asistencias/providers/overtime_provider.dart';
import 'package:app_asistencias/ui/screens/overtime/overtime_format.dart';
import 'package:app_asistencias/ui/screens/overtime/overtime_time_picker_sheet.dart';
import 'package:app_asistencias/ui/widgets/custom_snackbar.dart';
import 'package:app_asistencias/ui/widgets/form_text_field.dart';

/// Formulario de solicitud anticipada de horas extra: la solicitud es un
/// bloque continuo de fecha y hora de inicio a fecha y hora de fin.
///
/// La persistencia y el envío viven en [OvertimeProvider].
class OvertimeRequestFormScreen extends StatefulWidget {
  /// Identifier de la asignación: el `project` que pide el endpoint.
  final int projectId;

  /// Día sugerido.
  final DateTime? initialDate;

  /// Hora de inicio sugerida, en minutos desde medianoche.
  final int? initialStartMinutes;

  /// Proyecto / asignación de origen.
  final String? contextLabel;

  const OvertimeRequestFormScreen({
    super.key,
    required this.projectId,
    this.initialDate,
    this.initialStartMinutes,
    this.contextLabel,
  });

  static const int minJustificationChars = 30;
  static const int maxJustificationChars = 1000;

  @override
  State<OvertimeRequestFormScreen> createState() =>
      _OvertimeRequestFormScreenState();
}

class _OvertimeRequestFormScreenState extends State<OvertimeRequestFormScreen>
    with WidgetsBindingObserver {
  static const double _controlHeight = 56;

  /// Tope de duración: más de 72 h seguidas es un error de dedo en la fecha,
  /// no una jornada real.
  static const Duration _maxDuration = Duration(hours: 72);

  final _formKey = GlobalKey<FormState>();
  final _justificationController = TextEditingController();
  final _scrollController = ScrollController();
  final OvertimeProvider _overtime = OvertimeProvider();

  late DateTime _start;
  late DateTime _end;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final now = DateTime.now();
    final day = OvertimeRequestModel.dateOnly(widget.initialDate ?? now);

    // 18 * 60 = 6:00 p.m., la franja típica de horas extra en planta.
    final startMinutes = widget.initialStartMinutes ?? 18 * 60;

    _start = day.add(Duration(minutes: startMinutes));
    _end = _start.add(const Duration(hours: 4));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _justificationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// El teclado tapa el contador de horas. Cada vez que crece el inset de
  /// abajo, la pagina baja hasta el final.
  @override
  void didChangeMetrics() {
    final inset = View.of(context).viewInsets.bottom;
    if (inset <= 0) return;

    _scrollToBottom();
  }

  /// `didChangeMetrics` corre en cada frame del teclado, asi que un salto seco
  /// por frame acompana la animacion del sistema en vez de competir con ella.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  // ---------------- cálculo en vivo ----------------

  Duration get _duration => _end.difference(_start);

  bool get _spansDays => OvertimeRequestModel.dateOnly(_end)
      .isAfter(OvertimeRequestModel.dateOnly(_start));

  bool get _startIsPast => !_start.isAfter(DateTime.now());

  bool get _hasValidRange =>
      !_startIsPast && _duration > Duration.zero && _duration <= _maxDuration;

  bool get _canSubmit =>
      !_isSubmitting &&
      _hasValidRange &&
      _justificationController.text.trim().length >=
          OvertimeRequestFormScreen.minJustificationChars;

  /// Mueve el fin cuando el inicio lo dejó atrás, conservando la duración.
  void _keepEndAfterStart(Duration previousDuration) {
    if (_end.isAfter(_start)) return;

    final keep = previousDuration > Duration.zero
        ? previousDuration
        : const Duration(hours: 4);

    _end = _start.add(keep);
  }

  int _minutesOf(DateTime d) => d.hour * 60 + d.minute;

  // ---------------- pickers ----------------

  Future<void> _pickDate({required bool isEnd}) async {
    final now = DateTime.now();
    final today = OvertimeRequestModel.dateOnly(now);
    final current = OvertimeRequestModel.dateOnly(isEnd ? _end : _start);

    final first = isEnd ? OvertimeRequestModel.dateOnly(_start) : today;
    final initial = current.isBefore(first) ? first : current;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: today.add(const Duration(days: 90)),
      helpText: isEnd ? 'Fecha de fin' : 'Fecha de inicio',
      cancelText: 'Cancelar',
      confirmText: 'Listo',
    );

    if (picked == null) return;

    setState(() {
      final previousDuration = _duration;
      final day = OvertimeRequestModel.dateOnly(picked);

      if (isEnd) {
        _end = day.add(Duration(minutes: _minutesOf(_end)));
      } else {
        _start = day.add(Duration(minutes: _minutesOf(_start)));
        _keepEndAfterStart(previousDuration);
      }
    });
  }

  Future<void> _pickTime({required bool isEnd}) async {
    final target = isEnd ? _end : _start;

    final picked = await OvertimeTimePickerSheet.show(
      context,
      title: isEnd ? 'Hora de fin' : 'Hora de inicio',
      initialMinutes: _minutesOf(target),
    );

    if (picked == null) return;

    setState(() {
      final previousDuration = _duration;

      if (isEnd) {
        _end =
            OvertimeRequestModel.dateOnly(_end).add(Duration(minutes: picked));
      } else {
        _start = OvertimeRequestModel.dateOnly(_start)
            .add(Duration(minutes: picked));
        _keepEndAfterStart(previousDuration);
      }
    });
  }

  // ---------------- envío ----------------

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_hasValidRange) {
      CustomSnackBar.show(context, 'Revise las fechas y horas', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final request = await _overtime.createRequest(
        projectId: widget.projectId,
        start: _start,
        end: _end,
        justification: _justificationController.text,
      );

      LogProvider.log(
        'Solicitud de horas extra creada: ${OvertimeFormat.dateRange(request)} '
        'de ${OvertimeFormat.duration(request.duration)}',
        type: LogType.info,
        origin: 'OvertimeRequestFormScreen',
      );

      if (!mounted) return;

      CustomSnackBar.show(
        context,
        'Solicitud enviada: ${OvertimeFormat.dateRange(request)} - '
        '${OvertimeFormat.duration(request.duration)}',
      );

      Navigator.pop(context, true);
    } catch (e) {
      LogProvider.log(
        'Error al crear solicitud de horas extra: $e',
        type: LogType.error,
        origin: 'OvertimeRequestFormScreen',
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      CustomSnackBar.show(context, 'No se pudo enviar la solicitud',
          isError: true);
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
        title: const Text('Solicitar horas extra'),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter, vertical: AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.contextLabel != null) ...[
                    _buildLabel('Asignación'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildContextChip(widget.contextLabel!),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  _buildLabel('Inicio'),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDateTimeRow(isEnd: false),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLabel('Fin'),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDateTimeRow(isEnd: true),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTotalDuration(),
                  const SizedBox(height: AppSpacing.xxl),
                  Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) _scrollToBottom();
                    },
                    child: FormTextField(
                      label: 'Justificación',
                      controller: _justificationController,
                      hint: '¿Por qué necesita hacer horas extra?',
                      isRequired: true,
                      maxLines: 4,
                      minChars: OvertimeRequestFormScreen.minJustificationChars,
                      maxChars: OvertimeRequestFormScreen.maxJustificationChars,
                      enabled: !_isSubmitting,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSubmitButton(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildContextChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.work_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fecha y hora en una sola fila: `[Mie 19 Ago 2026] [3:00 p.m.]`.
  Widget _buildDateTimeRow({required bool isEnd}) {
    final value = isEnd ? _end : _start;

    final date = _buildPickerField(
      icon: Icons.calendar_today_outlined,
      text: OvertimeFormat.fullDate(value),
      onTap: () => _pickDate(isEnd: isEnd),
    );
    final time = _buildPickerField(
      icon: Icons.schedule,
      text: OvertimeFormat.time(_minutesOf(value)),
      onTap: () => _pickTime(isEnd: isEnd),
    );

    // 20 px es donde la fecha completa deja de caber junto a la hora.
    if (MediaQuery.textScalerOf(context).scale(15) > 20) {
      return Column(
        children: [
          date,
          const SizedBox(height: AppSpacing.sm),
          time,
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 3, child: date),
        const SizedBox(width: AppSpacing.md),
        Expanded(flex: 2, child: time),
      ],
    );
  }

  Widget _buildPickerField({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isSubmitting ? null : onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: _controlHeight),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Contador de duración.
  Widget _buildTotalDuration() {
    if (!_hasValidRange) {
      final tooLong = _duration > _maxDuration;
      final startIsPast = _startIsPast;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg, horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          startIsPast
              ? 'Inicio no válido. Las horas extra se deben solicitar por adelantado.'
              : tooLong
                  ? 'Son más de 72 horas seguidas. Revise la fecha de fin.'
                  : 'El fin debe ser después del inicio',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.danger,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            OvertimeFormat.durationLong(_duration),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_spansDays) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Termina el ${OvertimeFormat.shortDate(_end)}',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _justificationController,
      builder: (context, _, __) {
        final enabled = _canSubmit;

        return ConstrainedBox(
          constraints: const BoxConstraints(
              minWidth: double.infinity, minHeight: _controlHeight),
          child: ElevatedButton(
            onPressed: enabled ? _submit : null,
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'ENVIAR SOLICITUD',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
