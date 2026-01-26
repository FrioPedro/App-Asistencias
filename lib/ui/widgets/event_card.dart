import 'package:flutter/material.dart';
import 'dart:ui'; // Necesario para ImageFilter.blur

// --- IMPORTANTE: Importamos el nuevo modelo con el Enum 'AssigmentType' ---
import '../../models/activity_model.dart';
import '../../models/assigment_model.dart';

/// Widget que muestra una tarjeta de evento/asignación
class EventCard extends StatelessWidget {
  /// Nombre del evento / Descripción
  final String eventName;

  /// Nombre de la empresa / Cliente
  final String companyName;

  /// Código único del evento / Document ID
  final String eventCode;

  /// Fecha y hora del evento
  final String dateTime;

  /// Tipo de asignación (Viene de assigment_model.dart)
  final AssigmentType assigmentType;

  /// Callback ejecutado al tocar la tarjeta
  final VoidCallback? onTap;

  /// Indica si el usuario está participando (muestra borde verde)
  final bool isParticipating;

  /// Icono grande difuminado de fondo (opcional, solo si participa)
  final IconData? actionIcon;

  /// Nombre de la tarea activa (ej: "TRANSPORTE")
  final String? activeTaskName;

  /// Indica si el registro está pendiente de sincronización (Offline)
  final bool hasPendingSync;

  /// Indica si se está procesando una acción (Bloquea clicks y muestra carga)
  final bool isLoading;

  /// Motivo del registro (entrada/salida), para vistas de historial.
  final MotiveType? motive;

  /// Constructor del EventCard
  const EventCard({
    super.key,
    required this.eventName,
    required this.companyName,
    required this.eventCode,
    required this.dateTime,
    // Valor por defecto usando el nuevo enum 'other'
    this.assigmentType = AssigmentType.other,
    this.onTap,
    this.isParticipating = false,
    this.actionIcon,
    this.activeTaskName, // <--- NUEVO PARÁMETRO
    this.hasPendingSync = false,
    this.isLoading = false,
    this.motive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap, // Bloquea el tap si está cargando
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        // Importante: clipBehavior recorta el ícono de fondo
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F), // Gris oscuro
          borderRadius: BorderRadius.circular(16),
          // Borde condicional: verde si participa
          border: isParticipating
              ? Border.all(color: const Color(0xFF4CAF50), width: 2.0)
              : null,
          // Sombra verde difuminada opcional
          boxShadow: isParticipating
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : const [],
        ),
        child: Stack(
          children: [
            // --- CAPA 1: ÍCONO DE FONDO (Si participa) ---
            if (isParticipating && actionIcon != null)
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
                        stops: [0.0, 0.2, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Stack(
                      children: [
                        // 1.1 Versión Borrosa (Glow)
                        Center(
                          child: ImageFiltered(
                            imageFilter:
                                ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                            child: Icon(
                              actionIcon,
                              size: 120,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                        // 1.2 Versión Nítida
                        Center(
                          child: Icon(
                            actionIcon,
                            size: 120,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // --- CAPA 2: CONTENIDO DE LA TARJETA ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // COLUMNA IZQUIERDA: Datos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          companyName,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          eventCode,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // La fecha (solo se muestra si se pasa, lógica controlada por el padre)
                        Text(
                          dateTime,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ÍCONO DE SINCRONIZACIÓN PENDIENTE (Offline)
                  if (hasPendingSync)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0, bottom: 4.0),
                      child: Icon(
                        Icons.cloud_off_outlined,
                        color: Colors.orangeAccent,
                        size: 20,
                      ),
                    ),

                  // COLUMNA DERECHA: Las etiquetas
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 1. Badge de Entrada/Salida (Historial) - Arriba de todo
                      if (motive != null) ...[
                        _buildMotiveTag(),
                        const SizedBox(height: 6),
                      ],

                      // 2. FILA DE ESTADO (Actividad + Tipo)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // A. Badge de Actividad actual (A la izquierda)
                          if (isParticipating && activeTaskName != null) ...[
                            _buildActiveTaskBadge(),
                            const SizedBox(width: 6), // Espacio entre badges
                          ],

                          // B. Badge de Tipo de Asignación (A la derecha)
                          _buildAssignmentTypeTag(),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),

            // --- CAPA 3: ESTADO DE CARGA (Bloqueo visual) ---
            if (isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), // Oscurece la tarjeta
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4CAF50), // Verde corporativo
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Construye la etiqueta de "ACTIVIDAD EN CURSO" (ej: TALLER)
  Widget _buildActiveTaskBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4), // Fondo oscuro semitransparente
        border: Border.all(color: const Color(0xFF4CAF50)), // Borde verde neón
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pequeño punto indicador
          const Icon(Icons.circle, size: 6, color: Color(0xFF4CAF50)),
          const SizedBox(width: 4),
          Text(
            activeTaskName!.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900, // Letra muy gruesa
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la etiqueta para el tipo de asignación (proyectos, servicios, etc.)
  Widget _buildAssignmentTypeTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getTagColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      // Usamos .label de tu extensión en assigment_model.dart
      child: Text(
        assigmentType.label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Construye la etiqueta para el motivo del registro (Entrada/Salida)
  Widget _buildMotiveTag() {
    final isEntry = motive == MotiveType.entry;
    final label = isEntry ? 'ENTRADA' : 'SALIDA';
    final color = isEntry ? const Color(0xFF4CAF50) : const Color(0xFFFF6B6B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Retorna el color de la etiqueta según el tipo de asignación
  Color _getTagColor() {
    switch (assigmentType) {
      case AssigmentType.emergency:
        return const Color(0xFFFF6B6B); // Rojo (Emergencia)

      case AssigmentType.technicalVisit:
      case AssigmentType.serviceProject:
        return const Color(0xFF2E60C4); // Azul (Servicios)

      case AssigmentType.projectOrder:
      case AssigmentType.projectAdditional:
        return const Color(0xFF4CAF50); // Verde (Proyectos)

      case AssigmentType.warrantyProject:
        return const Color(0xFFFFC107); // Amarillo (Garantía)

      case AssigmentType.transfer:
        return const Color(0xFF9C27B0); // Morado (Traslados)

      case AssigmentType.officeAssistance:
      case AssigmentType.other:
        return Colors.white.withOpacity(0.1); // Gris (Otros)
    }
  }
}