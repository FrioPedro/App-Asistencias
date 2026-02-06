// ============================================================================
// SessionGroupCard - Widget para visualizar grupos de asistencias
// ============================================================================
// Un widget reutilizable que muestra información de una sesión agrupada
// por keyGroup con detalles de entrada, salida, duración y estado de sync.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:app_asistencias/providers/history_provider.dart';
import 'package:app_asistencias/domain/keygroup/keygroup_extensions.dart';
import 'package:app_asistencias/models/assigment_model.dart';
import 'package:app_asistencias/models/taskType_model.dart';

class SessionGroupCard extends StatelessWidget {
  final ActivitySession session;
  final VoidCallback? onTap;
  final bool showKeyGroup;
  final bool compactMode;

  const SessionGroupCard({
    super.key,
    required this.session,
    this.onTap,
    this.showKeyGroup = false,
    this.compactMode = false,
  });

  Color _getStatusColor() {
    if (session.isOngoing) {
      return const Color(0xFF4CAF50); // Verde para en curso
    }
    if (session.hasPendingSync) {
      return const Color(0xFFFF9800); // Naranja para pendiente de sync
    }
    return const Color(0xFF2E60C4); // Azul para completado
  }

  IconData _getActivityIcon() {
    switch (session.activityType) {
      case AssigmentType.projectOrder:
        return Icons.folder_outlined;
      case AssigmentType.serviceProject:
        return Icons.build_outlined;
      case AssigmentType.projectAdditional:
        return Icons.add_box_outlined;
      case AssigmentType.warrantyProject:
        return Icons.verified_outlined;
      case AssigmentType.emergency:
        return Icons.warning_outlined;
      case AssigmentType.technicalVisit:
        return Icons.search_outlined;
      case AssigmentType.officeAssistance:
        return Icons.apartment_outlined;
      case AssigmentType.transfer:
        return Icons.local_shipping_outlined;
      case AssigmentType.other:
      default:
        return Icons.work_outline;
    }
  }

  String _getStatusLabel() {
    if (session.isOngoing) return 'En curso';
    if (session.hasPendingSync) return 'Pendiente';
    return 'Completado';
  }

  @override
  Widget build(BuildContext context) {
    if (compactMode) {
      return _buildCompactCard();
    }
    return _buildFullCard();
  }

  Widget _buildCompactCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Indicador de estado
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Icono
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getActivityIcon(),
                color: _getStatusColor(),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.task.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.timeRange,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Duración
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                session.formattedDuration,
                style: TextStyle(
                  color: _getStatusColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Icono de actividad
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getActivityIcon(),
                        color: _getStatusColor(),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Título y descripción
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.description ?? 'Sin descripción',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            session.client ?? 'Sin cliente',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Badge de estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor().withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (session.isOngoing)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(),
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(
                            _getStatusLabel(),
                            style: TextStyle(
                              color: _getStatusColor(),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Container(
                  height: 1,
                  color: Colors.grey[800],
                ),

                const SizedBox(height: 16),

                // Footer - Tiempos
                Row(
                  children: [
                    // Entrada
                    Expanded(
                      child: _buildTimeInfo(
                        icon: Icons.login_rounded,
                        label: 'Entrada',
                        time: session.formattedEntryTime,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),

                    // Separador
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[800],
                    ),

                    // Salida
                    Expanded(
                      child: _buildTimeInfo(
                        icon: Icons.logout_rounded,
                        label: 'Salida',
                        time: session.formattedExitTime ?? '--:--',
                        color: session.isOngoing
                            ? Colors.grey
                            : const Color(0xFFF44336),
                      ),
                    ),

                    // Separador
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[800],
                    ),

                    // Duración
                    Expanded(
                      child: _buildTimeInfo(
                        icon: Icons.timer_outlined,
                        label: 'Duración',
                        time: session.formattedDuration,
                        color: _getStatusColor(),
                      ),
                    ),
                  ],
                ),

                // KeyGroup (opcional)
                if (showKeyGroup) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.key_rounded,
                          color: Colors.grey[600],
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ID: ${session.keyGroup}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Indicador de sync pendiente
                if (session.hasPendingSync) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF9800).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.sync_rounded,
                          color: Color(0xFFFF9800),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pendiente de sincronización',
                          style: TextStyle(
                            color: const Color(0xFFFF9800).withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
