import 'package:flutter/material.dart';
import 'dart:ui'; // Necesario para ImageFilter.blur

import '../../../models/assigment_model.dart';

/// Widget que muestra una tarjeta de evento/asignación (Home)
class EventCard extends StatelessWidget {
  /// Nombre del evento / Descripción
  final String eventName;

  /// Nombre de la Tarea (Oficina, Taller, etc.) - OPCIONAL
  /// Si es null, no se muestra ni el texto azul ni la imagen de fondo.
  final String? taskName;

  /// Nombre de la empresa / Cliente
  final String companyName;

  /// Código único del evento / Document ID
  final String eventCode;

  /// Hora de inicio formateada
  final String? startTime;

  /// Hora de fin (opcional, para UI futura)
  final String? endTime;

  /// Indica si el usuario está participando activamente en este evento
  final bool isParticipating;

  /// Nombre de la actividad activa actualmente (si isParticipating es false)
  final String? activeTaskName;

  /// Tipo de asignación (Emergencia, Servicio, etc.)
  final AssigmentType assigmentType;

  /// Callback al presionar TODA la tarjeta
  final VoidCallback? onTap;

  /// Constructor del EventCard
  const EventCard({
    super.key,
    required this.eventName,
    this.taskName, // Opcional
    required this.companyName,
    required this.eventCode,
    this.startTime,
    this.endTime,
    this.isParticipating = false,
    this.activeTaskName,
    this.assigmentType = AssigmentType.other,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior:
          Clip.antiAlias, // Para recortar la imagen de fondo y el ripple
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F), // Gris oscuro
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white10,
          highlightColor: Colors.white10,
          child: Stack(
            children: [
              // --- CAPA 1: IMAGEN/ICONO DE FONDO DIFUMINADO ---
              // SOLO si hay taskName
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HEADER: TIPO DE ASIGNACIÓN + ACTIVIDAD (SI EXISTE)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // A) TIPO DE ASIGNACIÓN (Siempre visible)
                        // Si es Emergencia -> Rojo
                        // Si no -> Gris/Blanco
                        Text(
                          assigmentType.label.toUpperCase(),
                          style: TextStyle(
                            color: _isAlert(assigmentType)
                                ? const Color(0xFFC62828) // Rojo
                                : Colors.grey[500], // Gris
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),

                        // B) Nombre de la Tarea (SOLO SI taskName != null)
                        if (taskName != null) ...[
                          Text(
                            ' - ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            taskName!.toUpperCase(),
                            style: TextStyle(
                              color: _getTaskColor(
                                  taskName!), // Color dinámico (Azul, etc)
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 2),

                    // 2. DESCRIPCIÓN (Nombre del evento/proyecto)
                    Text(
                      eventName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
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

                    if (startTime != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Inicio: $startTime',
                        style: TextStyle(
                          color: isParticipating
                              ? const Color(0xFF82B1FF)
                              : Colors.grey[400],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    if (!isParticipating && activeTaskName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Actividad en curso: $activeTaskName',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isAlert(AssigmentType type) {
    return type == AssigmentType.emergency;
  }

  // --- Helpers UI (Colores e Imágenes) ---

  Widget _buildBackgroundContent() {
    // Si no hay tarea específica, fondo vacío (para que "no salga nada por default")
    if (taskName == null) return const SizedBox.shrink();

    final imageAsset = _getTaskImageAsset(taskName!);

    if (imageAsset != null) {
      return Opacity(
        opacity: 0.6, // Un poco transparente
        child: Image.asset(
          imageAsset,
          fit: BoxFit.cover,
        ),
      );
    }

    // Fallback: Icono si no hay imagen
    final iconData = _getTaskIcon(taskName!);
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

  final String _iconsPath = 'assets/images/icons-tarjetas';

  Color _getTaskColor(String taskName) {
    final name = taskName.toLowerCase();
    if (name.contains('oficina')) return Colors.grey;
    if (name.contains('taller')) return const Color(0xFF4CAF50); // Verde
    if (name.contains('transporte')) return const Color(0xFFFF9800); // Naranja
    if (name.contains('servicio')) return const Color(0xFF2E60C4); // Azul
    return const Color(0xFF2E60C4); // Default Azul
  }

  String? _getTaskImageAsset(String taskName) {
    final name = taskName.toLowerCase();
    if (name.contains('oficina')) {
      return '$_iconsPath/oficina.jpg';
    }
    if (name.contains('taller')) {
      return '$_iconsPath/taller.jpg';
    }
    if (name.contains('servicio')) {
      return '$_iconsPath/servicio.jpg';
    }
    if (name.contains('transporte')) {
      return '$_iconsPath/transporte.jpg';
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
