import 'package:flutter/material.dart';
import 'dart:async';
import '../../../models/assigment_model.dart';
import '../../../models/activity_model.dart';
import '../../../providers/events_provider.dart';
import 'package:app_asistencias/providers/notes_provider.dart';

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
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  final EventsProvider _eventsService = EventsProvider();
  final NotesProvider _notesProvider = NotesProvider();

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(5),
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
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isError
                        ? const Color(0xFFFF5252).withOpacity(0.2)
                        : const Color(0xFF4CAF50).withOpacity(0.2),
                  ),
                  child: Icon(
                    isError ? Icons.close : Icons.check,
                    color: isError
                        ? const Color(0xFFFF5252)
                        : const Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
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

  Future<void> _handleSubmit() async {
    if (_descriptionController.text.trim().isEmpty) {
      _showOverlayToast(
        'Por favor, ingresa una descripción de la tarea.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sid = widget.event.serverId;
      if (sid != null) {
        await _eventsService.endAttendance(
          serverId: sid,
          //description: ,
        );

        await _notesProvider.createNote(
            document: sid.toString(),
            description:
                "[Reporte ${widget.task.label}]: ${_descriptionController.text.trim()}");
      }

      if (mounted) {
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 20.0,
        // ✅ 2. SUBIMOS EL CONTENIDO DEL MODAL
        // Aumentamos de 40 a 100. Esto empuja el botón hacia arriba
        // dejando espacio vacío abajo para que el mensaje no lo tape.
        bottom: bottomInset + 100.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 48.0),
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
                  icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Describe qué actividades realizaste...',
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF5350),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey,
              ),
              child: _isLoading
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
        ],
      ),
    );
  }
}
