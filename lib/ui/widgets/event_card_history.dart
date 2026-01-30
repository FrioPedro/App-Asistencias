import 'package:flutter/material.dart';
import 'dart:ui'; // Necesario para ImageFilter.blur
import '../../models/assigment_model.dart'; // Import para AssigmentType

/// Widget que muestra una tarjeta de historial con entrada y salida agrupadas
class EventCard extends StatelessWidget {
  /// Nombre del evento / Descripción
  final String eventName;

  /// Nombre de la Tarea (Oficina, Taller, etc.)
  final String taskName;

  /// Nombre de la empresa / Cliente
  final String companyName;

  /// Código único del evento / Document ID
  final String eventCode;

  /// Hora de inicio formateada
  final String? entryTime;

  /// Hora de salida formateada
  final String? exitTime;

  /// Indica si el registro está pendiente de sincronización (Offline)
  final bool hasPendingSync;

  /// Tipo de asignación (Emergencia, Servicio, etc.)
  final AssigmentType assigmentType;

  /// Constructor del EventCard
  const EventCard({
    super.key,
    required this.eventName,
    required this.taskName,
    required this.companyName,
    required this.eventCode,
    this.entryTime,
    this.exitTime,
    this.hasPendingSync = false,
    this.assigmentType = AssigmentType.other,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias, // Para recortar la imagen de fondo
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F), // Gris oscuro
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // --- CAPA 1: IMAGEN/ICONO DE FONDO DIFUMINADO ---
          Positioned(
            right: -30,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 180,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black,
                    ],
                    stops: [0.0, 0.1, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: _buildBackgroundContent(),
              ),
            ),
          ),

          // --- CAPA 2: CONTENIDO DE LA TARJETA ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ALERTA (ROJO) + '-' (GRIS) + NOMBRE DE ACTIVIDAD (AZUL) + ICONO CLOUD OPCIONAL (ÁMBAR)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Alerta Roja (ej: - EMERGENCIA)
                    if (_isAlert(assigmentType))
                      Row(
                        children: [
                          Text(
                            assigmentType.label.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFFF4C4C), // Rojo alerta
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            ' - ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    Text(
                      taskName.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF2E60C4), // Azul distintivo
                        fontSize: 11, // Un poco más pequeño
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    // Icono offline al lado del nombre de actividad
                    if (hasPendingSync) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.cloud_off_outlined,
                        color: Colors.orangeAccent,
                        size: 14,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 2),

                // 2. DESCRIPCIÓN (Nombre de la actividad realizada)
                Text(
                  eventName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15, // Ligera reducción
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                // 3. CLIENTE
                Text(
                  companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),

                // 4. DOCUMENTO
                Text(
                  eventCode,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 6),

                // 5. TIEMPOS (Inicio y Salida en línea pequeña)
                if (entryTime != null || exitTime != null)
                  Row(
                    children: [
                      _buildTimeChip('Inicio:', entryTime),
                      if (exitTime != null && exitTime!.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Container(
                            width: 1,
                            height: 12,
                            color: Colors.grey[700]), // Separador
                        const SizedBox(width: 12),
                        _buildTimeChip('Salida:', exitTime),
                      ]
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isAlert(AssigmentType type) {
    // Definimos qué tipos se consideran "alertas" para mostrar en rojo
    // Según el User Request: "alertas que dicen por ejemplo emergencia"
    // Vamos a incluir Emergencia y quizás otros críticos si los hubiera.
    return type == AssigmentType.emergency;
  }

  Widget _buildTimeChip(String label, String? time) {
    if (time == null || time.isEmpty) return const SizedBox.shrink();
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12),
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(color: Colors.grey[500]),
          ),
          TextSpan(
            text: time,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Lógica para recuperar la imagen basada en el nombre de la tarea
  // Copiada y simplificada de home/card.dart
  Widget _buildBackgroundContent() {
    final imageAsset = _getTaskImageAsset(taskName);

    if (imageAsset != null) {
      return Opacity(
        opacity: 0.6, // Un poco transparente para que no compita con el texto
        child: Image.asset(
          imageAsset,
          fit: BoxFit.cover,
        ),
      );
    }

    // Fallback: Icono si no hay imagen
    final iconData = _getTaskIcon(taskName);
    return Stack(
      children: [
        Center(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Icon(
              iconData,
              size: 100,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        Center(
          child: Icon(
            iconData,
            size: 100,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  String? _getTaskImageAsset(String taskName) {
    final name = taskName.toLowerCase();
    if (name.contains('oficina')) {
      return 'assets/images/icons-tarjetas/oficina.jpg';
    }
    if (name.contains('taller')) {
      return 'assets/images/icons-tarjetas/taller.jpg';
    }
    if (name.contains('servicio')) {
      return 'assets/images/icons-tarjetas/servicio.jpg';
    }
    if (name.contains('transporte')) {
      return 'assets/images/icons-tarjetas/transporte.jpg';
    }
    return null;
  }

  IconData _getTaskIcon(String taskName) {
    final name = taskName.toLowerCase();
    if (name.contains('oficina')) return Icons.business;
    if (name.contains('taller')) return Icons.build;
    if (name.contains('servicio')) return Icons.construction;
    if (name.contains('transporte')) return Icons.local_shipping;
    return Icons.work;
  }
}
