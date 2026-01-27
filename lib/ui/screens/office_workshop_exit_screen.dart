import 'package:flutter/material.dart';
import '../../models/assigment_model.dart';
import '../../models/activity_model.dart';
import '../../providers/events_provider.dart';

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
  State<OfficeWorkshopExitModal> createState() => _OfficeWorkshopExitModalState();
}

class _OfficeWorkshopExitModalState extends State<OfficeWorkshopExitModal> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  final EventsProvider _eventsService = EventsProvider();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa una descripción de la tarea.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sid = widget.event.serverId;
      if (sid != null) {
        await _eventsService.endAttendance(
          serverId: sid,
          description: _descriptionController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context, true); // Retorna true para indicar éxito
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al finalizar: $e'),
            backgroundColor: Colors.red,
          ),
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
    // Usamos padding inferior para el teclado
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 20.0,
        bottom: bottomInset + 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Modal se ajusta al contenido
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- HEADER CON TÍTULO Y CERRAR ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reporte de ${widget.task.label}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ----------------------------------

          Container(
            height: 150, // Altura fija para el área de texto
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
                backgroundColor: const Color(0xFFEF5350), // Rojo para salida
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
