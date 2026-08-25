import 'package:app_asistencias/ui/widgets/form_text_field.dart';
import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';
import 'dart:async';
import '../../../models/assigment_model.dart';
import '../../../providers/attendance_provider.dart';
import 'package:app_asistencias/providers/notes_provider.dart';
import 'package:app_asistencias/providers/log_provider.dart';
import 'package:app_asistencias/models/log_model.dart';
import 'package:app_asistencias/models/taskType_model.dart';
import 'package:app_asistencias/models/activity/list_form_model.dart';

class OfficeWorkshopExitModal extends StatefulWidget {
  final AssigmentModel event;
  final TaskType task;
  final String eventKey;

  const OfficeWorkshopExitModal({
    super.key,
    required this.event,
    required this.task,
    required this.eventKey,
  });

  @override
  State<OfficeWorkshopExitModal> createState() =>
      _OfficeWorkshopExitModalState();
}

class _OfficeWorkshopExitModalState extends State<OfficeWorkshopExitModal> {
  final AttendanceProvider _eventsService = AttendanceProvider();
  final NotesProvider _notesProvider = NotesProvider();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE MENSAJE FLOTANTE ---
  void _showOverlayToast(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // ✅ 1. EL MENSAJE SE QUEDA ABAJO (Posición original)
        bottom: bottomInset + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter, vertical: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xs),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isError
                        ? AppColors.danger.withOpacity(0.2)
                        : AppColors.success.withOpacity(0.2),
                  ),
                  child: Icon(
                    isError ? Icons.close : Icons.check,
                    color: isError ? AppColors.danger : AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;

    final formValid = _formKey.currentState!.validate();

    if (!formValid) {
      LogProvider.log(
          'Intento de envío de formulario de oficina fallido: Campos obligatorios incompletos',
          type: LogType.warning,
          origin: 'OfficeWorkshopExitScreen');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final sid = widget.eventKey;
      if (sid != null) {
        await _eventsService.endAttendance(
          keyGroup: sid,
          //description: ,
        );

        await _notesProvider.createNote(
            taskType: widget.task,
            document: sid.toString(),
            description:
                "[Reporte ${widget.task.label}]: ${_descriptionController.text.trim()}",
            type: ListForm.acciones);
      }

      if (mounted) {
        LogProvider.log(
          'Formulario ${widget.task.label} subido para OT: ${widget.event.documentId}',
          type: LogType.info,
          origin: 'OfficeWorkshopExitModal',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showOverlayToast(
          'Error al finalizar: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xxxl),
                child: Text(
                  'Reporte de ${widget.task.label}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                right: -12,
                top: -8,
                child: IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.textSecondary, size: 28),
                  onPressed:
                      _isSubmitting ? null : () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormTextField(
                  controller: _descriptionController,
                  hint: 'Describe qué actividades realizaste...',
                  isRequired: true,
                  minChars: 10,
                  maxLines: 3,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: AppSpacing.ctaHeight,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      disabledBackgroundColor: AppColors.disabled,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Finalizar y Subir',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
