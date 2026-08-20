import 'package:flutter/material.dart';

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
  static const Color _bgColor = Color(0xFF18191D);
  static const Color _cardColor = Color(0xFF2C2C2C);
  static const Color _primaryBlue = Color(0xFF2E60C4);
  static const Color _errorRed = Color(0xFFEF5350);
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

  bool get _hasValidRange =>
      _duration > Duration.zero && _duration <= _maxDuration;

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
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Solicitar horas extra',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.contextLabel != null) ...[
                    _buildContextChip(widget.contextLabel!),
                    const SizedBox(height: 20),
                  ],
                  _buildLabel('Inicio'),
                  const SizedBox(height: 10),
                  _buildDateTimeRow(isEnd: false),
                  const SizedBox(height: 20),
                  _buildLabel('Fin'),
                  const SizedBox(height: 10),
                  _buildDateTimeRow(isEnd: true),
                  const SizedBox(height: 20),
                  _buildTotalDuration(),
                  const SizedBox(height: 28),
                  Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) _scrollToBottom();
                    },
                    child: FormTextField(
                      label: 'Justificación',
                      controller: _justificationController,
                      hint: '¿Por qué necesita hacer horas extra?',
                      isRequired: true,
                      maxLines: 5,
                      minChars: OvertimeRequestFormScreen.minJustificationChars,
                      maxChars: OvertimeRequestFormScreen.maxJustificationChars,
                      enabled: !_isSubmitting,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _primaryBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.work_outline, color: _primaryBlue, size: 20),
          const SizedBox(width: 12),
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

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildPickerField(
            icon: Icons.calendar_today_outlined,
            text: OvertimeFormat.fullDate(value),
            onTap: () => _pickDate(isEnd: isEnd),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildPickerField(
            icon: Icons.schedule,
            text: OvertimeFormat.time(_minutesOf(value)),
            onTap: () => _pickTime(isEnd: isEnd),
          ),
        ),
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
        height: _controlHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[400], size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
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

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: _errorRed.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          tooLong
              ? 'Son más de 72 horas seguidas. Revise la fecha de fin.'
              : 'El fin tiene que ser después del inicio',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _errorRed,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: _primaryBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _primaryBlue.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            OvertimeFormat.durationLong(_duration),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_spansDays) ...[
            const SizedBox(height: 4),
            Text(
              'Termina el ${OvertimeFormat.shortDate(_end)}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
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

        return SizedBox(
          width: double.infinity,
          height: _controlHeight,
          child: ElevatedButton(
            onPressed: enabled ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              disabledBackgroundColor: Colors.grey[800],
              disabledForegroundColor: Colors.grey[500],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
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
                    'ENVIAR SOLICITUD',
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
