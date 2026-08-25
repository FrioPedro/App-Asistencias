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

/// Formulario de justificacion de horas extra ya trabajadas: el bloque es
/// continuo, de fecha y hora de inicio a fecha y hora de fin.
///
/// Las horas extra no se piden por adelantado, se justifican despues. El
/// objetivo del proceso es que no haya horas extra, porque indican mal manejo
/// del supervisor o falta de personal, asi que la ventana permitida es corta:
/// el dia actual y [_businessDaysBack] dias habiles hacia atras.
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

  /// Acordado con operaciones: el operario justifica el dia actual y los 3
  /// dias habiles anteriores, no mas.
  static const int _businessDaysBack = 3;

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

  DateTime get _today => OvertimeRequestModel.dateOnly(DateTime.now());

  /// Primer dia justificable: se retrocede saltando sabados y domingos.
  DateTime get _earliestDay {
    var day = _today;
    var remaining = _businessDaysBack;

    while (remaining > 0) {
      day =
          OvertimeRequestModel.dateOnly(day.subtract(const Duration(days: 1)));
      if (day.weekday != DateTime.saturday && day.weekday != DateTime.sunday) {
        remaining--;
      }
    }

    return day;
  }

  /// El fin no llega a superar al inicio: el bloque no tiene duracion.
  bool get _endNotAfterStart => _duration <= Duration.zero;

  bool get _endOutOfRange => _endNotAfterStart;

  // bool get _hasValidRange => !_endOutOfRange;

  bool get _canSubmit =>
      !_isSubmitting &&
      !_endOutOfRange &&
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

    final startDay = OvertimeRequestModel.dateOnly(_start);

    // El inicio se elige dentro de la ventana habil; el fin arranca en el dia
    // del inicio y llega hasta donde alcanza [_maxDuration], para el turno que
    // cruza medianoche.
    final first = isEnd ? startDay : _earliestDay;
    final last = isEnd ? startDay.add(_maxDuration) : today;

    final initial = current.isBefore(first)
        ? first
        : (current.isAfter(last) ? last : current);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
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
    if (_endOutOfRange) {
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
        title: const Text('Justificar horas extra'),
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
                  _buildContextChip(
                      Icons.warning_amber,
                      'Tienes $_businessDaysBack días hábiles para justificar tus horas extra.',
                      false, AppColors.warning),
                  const SizedBox(height: AppSpacing.xl),
                  if (widget.contextLabel != null) ...[
                    _buildLabel('Asignación'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildContextChip(
                        Icons.work_outline, widget.contextLabel!, true, AppColors.primary),
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
                      hint: 'Justifique a su supervisor',
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

  Widget _buildContextChip(IconData icon, String label, bool ellipsis, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: AppColors.textSecondary,
              size: MediaQuery.textScalerOf(context).scale(20)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              overflow: ellipsis ? TextOverflow.ellipsis : null,
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

    // Los dos mensajes de error mandan a corregir el fin, asi que solo se
    // marcan sus selectores.
    final hasError = isEnd && _endOutOfRange;

    final date = _buildPickerField(
      icon: Icons.calendar_today_outlined,
      text: OvertimeFormat.fullDate(value),
      onTap: () => _pickDate(isEnd: isEnd),
      hasError: hasError,
    );
    final time = _buildPickerField(
      icon: Icons.schedule,
      text: OvertimeFormat.time(_minutesOf(value)),
      onTap: () => _pickTime(isEnd: isEnd),
      hasError: hasError,
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
    bool hasError = false,
  }) {
    return GestureDetector(
      onTap: _isSubmitting ? null : onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: _controlHeight),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color:
              hasError ? AppColors.danger.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border:
              hasError ? Border.all(color: AppColors.danger, width: 1.5) : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: hasError ? AppColors.danger : AppColors.textSecondary,
                size: 20),
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
    if (_endOutOfRange) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg, horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Text(
          'El fin debe ser después del inicio',
          textAlign: TextAlign.center,
          style: TextStyle(
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
        color: AppColors.danger.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.danger.withOpacity(0.4)),
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

        return ElevatedButton(
          onPressed: enabled ? _submit : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(_controlHeight),
            backgroundColor: AppColors.danger,
          ),
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
                  'SOLICITAR APROBACIÓN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
        );
      },
    );
  }
}
