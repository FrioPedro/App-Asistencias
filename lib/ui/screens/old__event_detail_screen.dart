import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';

// --- IMPORTS ACTUALIZADOS ---
import '../../models/assigment_model.dart';          // Tu nuevo modelo
import '../../providers/old__event_detail_provider.dart'; // El provider

class EventDetailScreen extends StatefulWidget {
  // Ahora recibimos el nuevo modelo
  final AssigmentModel event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  // 1. Instancia del provider
  final EventDetailProvider _provider = EventDetailProvider();

  // 2. Estado para datos extra
  bool _isLoadingExtras = true;
  Map<String, dynamic> _extraDetails = {};

  @override
  void initState() {
    super.initState();
    _loadExtraDetails();
  }

  // Carga los datos que faltan usando el ID del documento
  Future<void> _loadExtraDetails() async {
    // Usamos el documentId (ej. ORD-001) o el ID numérico como respaldo
    final String searchId = widget.event.documentId ?? widget.event.id.toString();
    
    final details = await _provider.getExtraDetails(searchId);
    
    if (mounted) {
      setState(() {
        _extraDetails = details;
        _isLoadingExtras = false;
      });
    }
  }

  // Helper para formatear la fecha (DateTime -> String)
  String _formatDateTime(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    // Determinamos si es emergencia usando el nuevo Enum
    final isEmergency = widget.event.assigmentType == AssigmentType.emergency;

    // Preparamos los textos (Null Safety)
    final title = widget.event.description ?? 'Sin descripción';
    final client = widget.event.client ?? 'Cliente desconocido';
    final dateString = _formatDateTime(widget.event.updatedAt);
    final typeLabel = widget.event.assigmentType.label.toUpperCase(); // Usamos tu getter .label

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Menú de opciones
            }, 
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Etiqueta de Estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isEmergency 
                    ? AppColors.danger 
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sheet),
              ),
              child: Text(
                isEmergency ? 'EMERGENCIA' : typeLabel, // Mostramos la etiqueta real
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Título (Descripción) y Empresa (Cliente)
            Text(
              title,
              style: const TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: Colors.white
              ),
            ),
            const SizedBox(height: 8),
            Text(
              client,
              style: const TextStyle(
                fontSize: 18, 
                color: AppColors.textSecondary
              ),
            ),
            const SizedBox(height: 32),

            // 3. Tarjeta de Mapa
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sheet),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 40, color: AppColors.textSecondary),
                    SizedBox(height: 8),
                    Text(
                      'Cargando ubicación...', 
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 4. Detalles de la Asignación
            
            // Fecha (Convertida de DateTime)
            _buildDetailRow(Icons.calendar_today, 'Fecha', dateString),
            const SizedBox(height: 24),
            
            // Horario (Viene del provider)
            _isLoadingExtras 
                ? _buildLoadingRow() 
                : _buildDetailRow(Icons.access_time, 'Horario', _extraDetails['schedule'] ?? 'No definido'),
            
            const SizedBox(height: 24),
            
            // Supervisor (Viene del provider)
            _isLoadingExtras 
                ? _buildLoadingRow() 
                : _buildDetailRow(Icons.person_outline, 'Supervisor', _extraDetails['supervisor'] ?? 'No asignado'),
            
            const SizedBox(height: 40),

            // 5. Botón de Acción
            SizedBox(
              width: double.infinity,
              height: AppSpacing.ctaHeight,
              child: ElevatedButton(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Función de registro iniciada"))
                   );
                },
                child: const Text(
                  'REGISTRAR ACTIVIDAD',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para filas de datos
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 16, 
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget esqueleto pequeño
  Widget _buildLoadingRow() {
    return Row(
      children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(AppRadius.md))),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 60, height: 10, color: Colors.white.withOpacity(0.05)),
            const SizedBox(height: 8),
            Container(width: 120, height: 14, color: Colors.white.withOpacity(0.05)),
          ],
        )
      ],
    );
  }
}