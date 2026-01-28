import 'package:flutter/material.dart';
import '../../../models/assigment_model.dart';
import '../../../providers/events_provider.dart';
import '../../widgets/custom_snackbar.dart';

class ServiceExitFormScreen extends StatefulWidget {
  final AssigmentModel event;
  final String eventKey;

  const ServiceExitFormScreen({
    super.key,
    required this.event,
    required this.eventKey,
  });

  @override
  State<ServiceExitFormScreen> createState() => _ServiceExitFormScreenState();
}

class _ServiceExitFormScreenState extends State<ServiceExitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incidenciasController = TextEditingController();
  final _conclusionesController = TextEditingController();
  final _recomendacionesController = TextEditingController();

  final EventsProvider _eventsService = EventsProvider();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _incidenciasController.dispose();
    _conclusionesController.dispose();
    _recomendacionesController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // 1. Aquí iría la lógica para subir las fotos y el reporte
      // Como no tenemos el endpoint aún, simulamos el envío.
      await Future.delayed(const Duration(seconds: 1));

      // 2. Finalizar la asistencia
      final sid = widget.event.serverId;
      if (sid != null) {
        await _eventsService.endAttendance(serverId: sid);
      }

      if (mounted) {
        // Retornamos 'true' para indicar que se finalizó con éxito
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, 'Error al finalizar: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF121212);
    const cardColor = Color(0xFF2C2C2C);
    // const primary = Color(0xFF2E60C4); // Azul corporativo (o el que corresponda)

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Finalizar Servicio',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('FOTOGRAFÍAS'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildPhotoBox('ANTES')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildPhotoBox('DESPUÉS')),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  label: 'INCIDENCIAS',
                  controller: _incidenciasController,
                  hint: 'Describa las incidencias encontradas...',
                  cardColor: cardColor,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  label: 'CONCLUSIONES',
                  controller: _conclusionesController,
                  hint: 'Conclusiones del servicio...',
                  cardColor: cardColor,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  label: 'RECOMENDACIONES',
                  controller: _recomendacionesController,
                  hint: 'Recomendaciones para el cliente...',
                  cardColor: cardColor,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFEF5350), // Rojo para salida
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'FINALIZAR SERVICIO',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildPhotoBox(String label) {
    return InkWell(
      onTap: () {
        CustomSnackBar.show(
            context, 'Funcionalidad de cámara pendiente de configurar',
            isError: true);
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, color: Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required Color cardColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Este campo es obligatorio'
                : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16.0),
            ),
          ),
        ),
      ],
    );
  }
}
