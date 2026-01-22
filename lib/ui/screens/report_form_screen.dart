import 'package:flutter/material.dart';

// --- IMPORTS ---
import '../../models/report_model.dart';          // Modelo
import '../../providers/report_form_provider.dart'; // Provider

class ReportFormScreen extends StatefulWidget {
  final String reportType;

  const ReportFormScreen({super.key, required this.reportType});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  // 1. Instancia del Provider
  final ReportFormProvider _provider = ReportFormProvider();

  final TextEditingController _notesController = TextEditingController();
  
  // Estado local
  bool _isLoading = false;
  
  // Simulación de fotos seleccionadas (true = foto tomada)
  bool _hasBeforePhoto = false;
  bool _hasAfterPhoto = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Lógica de Guardado
  Future<void> _submitForm() async {
    // Validación básica
    if (_notesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor añade detalles del trabajo'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Crear modelo
    final report = ReportModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: widget.reportType,
      description: _notesController.text,
      createdAt: DateTime.now(),
      beforePhotoPath: _hasBeforePhoto ? '/path/simulado/antes.jpg' : null,
      afterPhotoPath: _hasAfterPhoto ? '/path/simulado/despues.jpg' : null,
    );

    // Llamar al provider
    final success = await _provider.submitReport(report);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        // Mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte guardado correctamente'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );

        // Navegación: Volver 2 pasos atrás (Cierra Formulario y Selección)
        // Para regresar directo a la pantalla de Eventos/Principal
        Navigator.of(context).pop(); // Cierra Formulario
        Navigator.of(context).pop(); // Cierra Selección de Tipo
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Reporte: ${widget.reportType}', style: const TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECCIÓN 1: Evidencia Fotográfica
            const Text(
              'Evidencia Fotográfica',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sube fotos del antes y el después de la actividad.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: _buildPhotoUploadBox(
                    label: 'ANTES', 
                    icon: Icons.history, 
                    hasPhoto: _hasBeforePhoto,
                    onTap: () => setState(() => _hasBeforePhoto = !_hasBeforePhoto)
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoUploadBox(
                    label: 'DESPUÉS', 
                    icon: Icons.check_circle_outline, 
                    hasPhoto: _hasAfterPhoto,
                    onTap: () => setState(() => _hasAfterPhoto = !_hasAfterPhoto)
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // SECCIÓN 2: Descripción / Notas
            const Text(
              'Detalles del trabajo',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1F1F1F),
                hintText: 'Describe las actividades realizadas...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 40),

            // BOTÓN GUARDAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text(
                        'GUARDAR REPORTE',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget visual mejorado para simular estado de foto
  Widget _buildPhotoUploadBox({
    required String label, 
    required IconData icon, 
    required bool hasPhoto, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 150,
        decoration: BoxDecoration(
          color: hasPhoto ? const Color(0xFF4CAF50).withValues(alpha: 0.1) : const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(16),
          border: hasPhoto ? Border.all(color: const Color(0xFF4CAF50), width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasPhoto ? const Color(0xFF4CAF50) : Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasPhoto ? Icons.check : icon, 
                color: hasPhoto ? Colors.white : Colors.grey[400], 
                size: 30
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasPhoto ? 'FOTO CARGADA' : label,
              style: TextStyle(
                color: hasPhoto ? const Color(0xFF4CAF50) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasPhoto ? 'Toque para cambiar' : 'Toque para subir',
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}