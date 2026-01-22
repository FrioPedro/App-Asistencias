import 'package:flutter/material.dart';
import 'dart:ui'; // Necesario para ImageFilter.blur

/// Enum para clasificar el tipo de evento
/// - emergency: Evento de emergencia (rojo)
/// - technicalVisit: Visita técnica (azul)
/// - other: Otro tipo de evento (gris)
enum EventType { emergency, technicalVisit, other }

/// Widget que muestra una tarjeta de evento
/// Contiene información del evento y etiqueta de tipo.
/// Cuando isParticipating == true, muestra un efecto visual de borde verde y un ícono de fondo.
class EventCard extends StatelessWidget {
  /// Nombre del evento
  final String eventName;

  /// Nombre de la empresa/cliente
  final String companyName;

  /// Código único del evento
  final String eventCode;

  /// Fecha y hora del evento
  final String dateTime;

  /// Tipo de evento (Emergency, TechnicalVisit, Other)
  final EventType eventType;

  /// Callback ejecutado al tocar la tarjeta
  final VoidCallback? onTap;

  /// Indica si el usuario está participando (muestra borde verde)
  final bool isParticipating;

  /// Icono grande difuminado de fondo (opcional, solo si participa)
  final IconData? actionIcon;

  /// Método auxiliar para compatibilidad con código legacy
  static EventType fromIsEmergency(bool isEmergency) {
    if (isEmergency) return EventType.emergency;
    return EventType.other;
  }

  /// Constructor del EventCard
  const EventCard({
    super.key,
    required this.eventName,
    required this.companyName,
    required this.eventCode,
    required this.dateTime,
    this.eventType = EventType.other,
    this.onTap,
    this.isParticipating = false,
    this.actionIcon, // Nuevo parámetro
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        // Importante: clipBehavior recorta el ícono de fondo que se sale del contenedor
        // Esto evita que el efecto de blur se vea fuera de las esquinas redondeadas
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F), // Gris oscuro
          borderRadius: BorderRadius.circular(16),
          // Borde condicional: verde si participa, sin borde si no
          border: isParticipating
              ? Border.all(color: const Color(0xFF4CAF50), width: 2.0)
              : null,
          // Sombra verde difuminada opcional cuando participa
          boxShadow: isParticipating
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Stack(
          children: [
            // --- CAPA 1: ÍCONO DE FONDO CON EFECTO DE BARRIDO LINEAL ---
            // Solo se muestra si está participando y se le pasó un ícono.
            // Se coloca PRIMERO en el Stack para que quede DETRÁS del texto.
            if (isParticipating && actionIcon != null)
              Positioned(
                right: -30, // Desplazado a la derecha para efecto de corte
                top: 0, // Ocupa todo el alto verticalmente
                bottom: 0,
                child: SizedBox(
                  width: 180, // Ancho del área del ícono
                  // Usamos ShaderMask para aplicar el gradiente de transparencia
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent, // Izquierda: Totalmente invisible
                          Colors.transparent, // Punto medio: Sigue invisible para asegurar limpieza
                          Colors.black,       // Derecha: Visible (Opaco)
                        ],
                        // STOPS: 0.0 a 0.2 mantiene transparencia total.
                        // De 0.2 a 1.0 hace la transición a visible.
                        stops: [0.0, 0.2, 1.0], 
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn, // Aplica la máscara
                    child: Stack(
                      children: [
                        // 1.1 Versión Borrosa (Glow de fondo)
                        Center(
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                            child: Icon(
                              actionIcon,
                              size: 120, // Tamaño gigante
                              color: Colors.white.withOpacity(0.3), // Un poco más brillante
                            ),
                          ),
                        ),
                        // 1.2 Versión Nítida (Frente)
                        Center(
                          child: Icon(
                            actionIcon,
                            size: 120,
                            // Mismo color base pero con opacidad elegante
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // --- CAPA 2: CONTENIDO DE LA TARJETA (TEXTOS) ---
            // Se coloca DESPUÉS en el Stack para que siempre esté legible ENCIMA del ícono
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // COLUMNA IZQUIERDA: Textos
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

                  // COLUMNA DERECHA: La etiqueta (Tag)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTagColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getTagText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retorna el color de la etiqueta según el tipo de evento
  Color _getTagColor() {
    switch (eventType) {
      case EventType.emergency:
        return const Color(0xFFFF6B6B); // Rojo/Salmón para emergencias
      case EventType.technicalVisit:
        return const Color(0xFF2E60C4); // Azul para visitas técnicas
      case EventType.other:
        return Colors.white.withOpacity(0.1); // Gris transparente para otros
    }
  }

  /// Retorna el texto de la etiqueta según el tipo de evento
  String _getTagText() {
    switch (eventType) {
      case EventType.emergency:
        return 'EMERGENCIA';
      case EventType.technicalVisit:
        return 'VISITA TÉCNICA';
      case EventType.other:
        return 'OTRO';
    }
  }
}