import 'package:flutter/material.dart';

// --- IMPORTS ---
import '../../models/report_format_model.dart';          // Modelo
import '../../providers/report_selection_provider.dart'; // Provider
import 'report_form_screen.dart'; // Asegúrate de crear este archivo en el siguiente paso

class ReportSelectionScreen extends StatefulWidget {
  const ReportSelectionScreen({super.key});

  @override
  State<ReportSelectionScreen> createState() => _ReportSelectionScreenState();
}

class _ReportSelectionScreenState extends State<ReportSelectionScreen> {
  // 1. Instancia del Provider
  final ReportSelectionProvider _provider = ReportSelectionProvider();

  // 2. Estado local
  List<ReportFormatModel> _formats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  // Cargar las opciones del menú
  Future<void> _loadMenu() async {
    final menuItems = await _provider.getAvailableFormats();
    
    if (mounted) {
      setState(() {
        _formats = menuItems;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Seleccionar Formato', style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Qué tipo de reporte realizarás?',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 20),
            
            // GRID DE OPCIONES
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 columnas
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.4, // Proporción de las tarjetas
                      ),
                      itemCount: _formats.length,
                      itemBuilder: (context, index) {
                        final format = _formats[index];
                        return _buildFormatCard(context, format);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatCard(BuildContext context, ReportFormatModel format) {
    return GestureDetector(
      onTap: () {
        // Navegamos al formulario específico pasando el título del reporte
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportFormScreen(reportType: format.title),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: format.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(format.icon, color: format.color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              format.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}