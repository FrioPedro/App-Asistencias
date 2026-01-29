import 'package:flutter/material.dart';
import 'dart:ui'; // Necesario para ImageFilter.blur

// --- IMPORTANTE: Importamos el nuevo modelo con el Enum 'AssigmentType' ---
import '../../../models/activity_model.dart';
import '../../../models/assigment_model.dart';

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

  /// Controla si se muestra el badge de tipo de asignación
  final bool showAssignmentTypeBadge;

  // ... (rest of the fields are already there, just fixing the missing one and the usage)

  /// Controla si se muestra el badge del motivo (Entrada/Salida)
  final bool showMotiveBadge;

  /// Controla si se muestra el badge de la tarea activa (Taller/Oficina...)
  final bool showActiveTaskBadge;

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
    this.showAssignmentTypeBadge = true, // Por defecto se muestra
    this.showMotiveBadge = true,
    this.showActiveTaskBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    // Si es SALIDA, oscurecemos el fondo casi a negro
    final backgroundColor = (motive == MotiveType.exit)
        ? const Color(0xFF000000)
        : const Color(0xFF1F1F1F);

    return GestureDetector(
      onTap: isLoading ? null : onTap, // Bloquea el tap si está cargando
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        // Importante: clipBehavior recorta la imagen de fondo
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: backgroundColor, // Uso del color dinámico
          borderRadius: BorderRadius.circular(16),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // --- CAPA 1: ÍCONO DE FONDO (Si participa) ---
            // --- CAPA 1: IMAGEN DE FONDO (Si participa) ---
            if (isParticipating)
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          companyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          eventCode,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // La fecha (solo se muestra si se pasa, lógica controlada por el padre)
                        Text(
                          dateTime,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                      // FILA DE ESTADO (Motivo + Actividad + Tipo)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // A. Badge de Entrada/Salida (Si existe y está habilitado)
                          if (motive != null && showMotiveBadge) ...[
                            _buildMotiveTag(),
                            const SizedBox(width: 6),
                          ],

                          // B. Badge de Actividad actual (Si existe y está habilitado)
                          if (isParticipating &&
                              activeTaskName != null &&
                              showActiveTaskBadge) ...[
                            _buildActiveTaskBadge(),
                            const SizedBox(width: 6), // Espacio entre badges
                          ],

                          // C. Badge de Tipo de Asignación
                          if (showAssignmentTypeBadge)
                            _buildAssignmentTypeTag(),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),

            // --- CAPA 2.5: SOMBRADO OSCURO (Si es Salida) ---
            if (motive == MotiveType.exit)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withOpacity(0.5),
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
    final color = _getActiveColor();
    // Versión corta del nombre de la tarea
    final shortName = _getShortTaskName(activeTaskName!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4), // Fondo oscuro semitransparente
        border: Border.all(color: color), // Borde del color de la actividad
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pequeño punto indicador
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 4),
          Text(
            shortName,
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

  Widget _buildBackgroundContent() {
    final imageAsset = _getTaskImageAsset(activeTaskName);

    // Si es salida, la opacidad debe ser menor para que se vea oscuro
    final opacity = (motive == MotiveType.exit) ? 0.6 : 0.80;

    if (imageAsset != null) {
      return Opacity(
        opacity: opacity,
        child: Image.asset(
          imageAsset,
          fit: BoxFit.cover,
        ),
      );
    }

    if (actionIcon != null) {
      return Stack(
        children: [
          Center(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Icon(
                actionIcon,
                size: 120,
                color: _getActiveColor().withOpacity(0.5),
              ),
            ),
          ),
          Center(
            child: Icon(
              actionIcon,
              size: 120,
              color: _getActiveColor().withOpacity(0.3),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  String? _getTaskImageAsset(String? taskName) {
    if (taskName == null) return null;
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

  /// Obtiene la versión corta del nombre de la tarea
  String _getShortTaskName(String taskName) {
    final name = taskName.toLowerCase();
    if (name == 'oficina') return 'OFI';
    if (name == 'taller') return 'TAL';
    if (name == 'servicio') return 'SER';
    if (name == 'transporte') return 'TRA';
    return taskName.substring(0, 3).toUpperCase();
  }

  Color _getActiveColor() {
    if (activeTaskName != null) {
      return TaskTypeX.fromLabel(activeTaskName).color;
    }
    return const Color(0xFF4CAF50); // Default Green
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
    final label = isEntry ? 'ENT' : 'SAL'; // Versión corta
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
