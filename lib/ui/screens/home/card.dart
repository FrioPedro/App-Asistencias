import 'package:flutter/material.dart';
import 'dart:ui'; // Necesario para ImageFilter.blur

// --- IMPORTANTE: Importamos el nuevo modelo con el Enum 'AssigmentType' ---
import '../../../models/activity_model.dart';
import '../../../models/assigment_model.dart';

/// Widget que muestra una tarjeta de evento/asignación (Home)
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

  /// Indica si el usuario está participando
  final bool isParticipating;

  /// Icono grande difuminado de fondo (opcional, solo si participa)
  final IconData? actionIcon;

  /// Nombre de la tarea activa (ej: "TRANSPORTE")
  final String? activeTaskName;

  /// Indica si el registro está pendiente de sincronización (Offline)
  final bool hasPendingSync;

  /// Indica si se está procesando una acción (Bloquea clicks y muestra carga)
  final bool isLoading;

  /// Motivo del registro (entrada/salida)
  final MotiveType? motive;

  /// Controla si se muestra el badge de tipo de asignación (Ignorado ahora para estética minimal)
  final bool showAssignmentTypeBadge;
  final bool showMotiveBadge;
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
    this.activeTaskName,
    this.hasPendingSync = false,
    this.isLoading = false,
    this.motive,
    this.showAssignmentTypeBadge = true,
    this.showMotiveBadge = true,
    this.showActiveTaskBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    // Si es SALIDA, oscurecemos el fondo casi a negro (mantenido solo como sutil diferencia de fondo)
    final backgroundColor = (motive == MotiveType.exit)
        ? const Color(0xFF000000)
        : const Color(0xFF1F1F1F);

    // Determinamos el nombre de la tarea para mostrar
    final displayTaskName = activeTaskName ?? assigmentType.label;

    return GestureDetector(
      onTap: isLoading ? null : onTap, // Bloquea el tap si está cargando
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: backgroundColor, // Uso del color dinámico
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
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
                    child: _buildBackgroundContent(displayTaskName),
                  ),
                ),
              ),

            // --- CAPA 2.5: SOMBRADO OSCURO (Si es Salida) ---
            // Mantenemos esto para dar feedback visual sutil de que es una salida
            if (motive == MotiveType.exit)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),

            // --- CAPA 2: CONTENIDO DE LA TARJETA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. NOMBRE DE ACTIVIDAD (Primero) + Cloud Icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (activeTaskName == null &&
                          assigmentType == AssigmentType.emergency)
                        // CASO: Sin tarea activa y es Emergencia -> SOLO ROJO
                        Text(
                          assigmentType.label.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFFF4C4C), // Rojo alerta
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        )
                      else
                        // CASO NORMAL: Azul + (Opcional Rojo)
                        Row(
                          children: [
                            Text(
                              displayTaskName.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF2E60C4), // Azul distintivo
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (assigmentType == AssigmentType.emergency)
                              Row(
                                children: [
                                  const SizedBox(width: 4),
                                  Text(
                                    '- ',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    assigmentType.label.toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFFFF4C4C), // Rojo alerta
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                          ],
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

                  const SizedBox(height: 6),

                  // 5. FECHA/HORA
                  _buildTimeChip(dateTime),
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

  Widget _buildTimeChip(String time) {
    if (time.isEmpty) return const SizedBox.shrink();
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12),
        children: [
          // En Home suele ser la fecha/hora del evento actual o futuro,
          // asi que "Inicio:" podría ser asumido, pero el usuario pidió "Traslada la estética"
          // Si es solo una fecha larga, la mostraremos tal cual en blanco.
          TextSpan(
            text: time,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundContent(String taskName) {
    final imageAsset = _getTaskImageAsset(taskName);

    // Transparencia para imagen
    final opacity =
        (motive == MotiveType.exit) ? 0.6 : 0.6; // Similar al history card

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
      // Fallback con el icono que venía
      return _buildIconFallback(actionIcon!);
    }

    // Fallback buscando icono por nombre
    final iconData = _getTaskIcon(taskName);
    return _buildIconFallback(iconData);
  }

  Widget _buildIconFallback(IconData icon) {
    return Stack(
      children: [
        Center(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Icon(
              icon,
              size: 100, // Ajustado a 100 como en history card
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        Center(
          child: Icon(
            icon,
            size: 100,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ],
    );
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

  IconData _getTaskIcon(String taskName) {
    final name = taskName.toLowerCase();
    if (name.contains('oficina')) return Icons.business;
    if (name.contains('taller')) return Icons.build;
    if (name.contains('servicio')) return Icons.construction;
    if (name.contains('transporte')) return Icons.local_shipping;
    return Icons.work;
  }

  // --- Helpers de colores (mantenidos si se necesitan en futuro, o para fallbacks) ---
  Color _getActiveColor() {
    if (activeTaskName != null) {
      return TaskTypeX.fromLabel(activeTaskName).color;
    }
    return const Color(0xFF4CAF50); // Default Green
  }
}
