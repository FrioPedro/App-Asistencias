import 'package:flutter/material.dart';
import 'dart:ui'; // Necesario para ImageFilter.blur

import '../../../models/assigment_model.dart';

/// Widget que muestra una tarjeta de evento/asignación (Home)
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
  final String? startTime;

  /// Hora de fin (opcional, para UI futura)
  final String? endTime;

  /// Indica si el usuario está participando activamente en este evento
  final bool isParticipating;

  /// Nombre de la actividad activa actualmente (si isParticipating es false)
  final String? activeTaskName;

  /// Tipo de asignación (Emergencia, Servicio, etc.)
  final AssigmentType assigmentType;

  /// Callback al presionar "Ingresar"
  final VoidCallback? onEnter;

  /// Callback al presionar "Salida"
  final VoidCallback? onExit;

  /// Constructor del EventCard
  const EventCard({
    super.key,
    required this.eventName,
    required this.taskName,
    required this.companyName,
    required this.eventCode,
    this.startTime,
    this.endTime,
    this.isParticipating = false,
    this.activeTaskName, // Ahora opcional
    this.assigmentType = AssigmentType.other,
    this.onEnter,
    this.onExit,
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
                // 1. ALERTA (ROJO) + '-' (GRIS) + NOMBRE DE ACTIVIDAD (PERSONALIZADO)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Si es emergencia, mostrar texto rojo antes
                    if (_isAlert(assigmentType))
                      Row(
                        children: [
                          Text(
                            assigmentType.label.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFC62828), // Rojo Alerta
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
                    // Nombre de la Tarea (Oficina, Taller...)
                    Text(
                      taskName.toUpperCase(),
                      style: TextStyle(
                        color: _getTaskColor(taskName), // Color dinámico
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
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

                const SizedBox(height: 12),

                // 5. ACCIONES (BOTONES)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Caso A: Ya estoy participando en ESTA actividad -> Botón Salida
                    if (isParticipating)
                      _buildActionButton(
                        label: 'SALIDA',
                        color: const Color(0xFFC62828), // Rojo
                        icon: Icons.logout,
                        onPressed: onExit,
                      )
                    // Caso B: Estoy participando en OTRA actividad -> Texto informativo
                    else if (activeTaskName != null)
                      Flexible(
                        child: Text(
                          'Termina "$activeTaskName" para ingresar aquí',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    // Caso C: No estoy participando en nada -> Botón Ingresar
                    else
                      _buildActionButton(
                        label: 'INGRESAR',
                        color: const Color(0xFF2E60C4), // Azul
                        icon: Icons.login,
                        onPressed: onEnter,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un botón de acción estilizado
  Widget _buildActionButton({
    required String label,
    required Color color,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }

  bool _isAlert(AssigmentType type) {
    return type == AssigmentType.emergency;
  }

  // --- Helpers UI (Colores e Imágenes) ---

  // Lógica para recuperar la imagen basada en el nombre de la tarea
  // Se busca en assets/images/icons-tarjetas/[nombre].jpg
  Widget _buildBackgroundContent() {
    final imageAsset = _getTaskImageAsset(taskName);

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
    // Mapa manual de nombres a archivos
    // Asegurarse de que existan en la carpeta assets/images/icons-tarjetas/
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
