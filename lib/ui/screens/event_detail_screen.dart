import 'package:flutter/material.dart';

// --- IMPORTS ---
import '../../models/event_model.dart';          // Necesitamos el modelo
import '../../providers/event_detail_provider.dart'; // El nuevo provider

class EventDetailScreen extends StatefulWidget {
  // En lugar de pasar strings sueltos, pasamos el objeto completo
  final EventModel event;

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

  // Carga los datos que faltan (Supervisor, Horario, etc.)
  Future<void> _loadExtraDetails() async {
    final details = await _provider.getExtraDetails(widget.event.id);
    if (mounted) {
      setState(() {
        _extraDetails = details;
        _isLoadingExtras = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determinamos si es emergencia basado en el tipo del modelo
    final isEmergency = widget.event.type == EventType.emergency;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Aquí podrías poner "Reportar problema" o "Ver historial"
            }, 
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Etiqueta de Estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isEmergency 
                    ? const Color(0xFFFF6B6B) 
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isEmergency ? 'EMERGENCIA' : 'NORMAL',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Título y Empresa (Datos inmediatos del modelo)
            Text(
              widget.event.name,
              style: const TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: Colors.white
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.event.company,
              style: TextStyle(
                fontSize: 18, 
                color: Colors.grey[400]
              ),
            ),
            const SizedBox(height: 32),

            // 3. Tarjeta de Mapa
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(24),
                // Aquí podrías usar: image: DecorationImage(...) con un mapa estático
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 40, color: Colors.grey[600]),
                    const SizedBox(height: 8),
                    Text(
                      'Cargando ubicación...', // Podrías actualizar esto con _extraDetails['coordinates']
                      style: TextStyle(color: Colors.grey[500]),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 4. Detalles de la Asignación (Mezcla de datos inmediatos y cargados)
            
            // Fecha (Viene del modelo, inmediato)
            _buildDetailRow(Icons.calendar_today, 'Fecha', widget.event.dateTime),
            const SizedBox(height: 24),
            
            // Horario (Viene del provider, requiere carga)
            _isLoadingExtras 
                ? _buildLoadingRow() 
                : _buildDetailRow(Icons.access_time, 'Horario', _extraDetails['schedule'] ?? 'No definido'),
            
            const SizedBox(height: 24),
            
            // Supervisor (Viene del provider, requiere carga)
            _isLoadingExtras 
                ? _buildLoadingRow() 
                : _buildDetailRow(Icons.person_outline, 'Supervisor', _extraDetails['supervisor'] ?? 'No asignado'),
            
            const SizedBox(height: 40),

            // 5. Botón de Acción
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                   // Aquí puedes abrir el mismo modal de acciones que usas en la lista
                   // O navegar a una pantalla de reporte
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Función de registro iniciada"))
                   );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
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
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
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

  // Widget esqueleto pequeño para cuando carga el supervisor/horario
  Widget _buildLoadingRow() {
    return Row(
      children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12))),
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