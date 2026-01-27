import 'package:flutter/material.dart';
import '../../../../models/assigment_model.dart';
import '../../../../models/activity_model.dart';
import '../../../../providers/events_provider.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/action_option.dart';
import '../../service_exit_form_screen.dart';
import '../../office_workshop_exit_screen.dart';

class EventActionModal extends StatefulWidget {
  final AssigmentModel event;
  final String eventKey;
  final bool isActiveSession;
  final IconData? activeIcon;
  final String? activeTaskName;
  final Function(String eventKey, IconData icon, String taskName)
      onSessionStarted;
  final Function(String eventKey) onSessionEnded;

  const EventActionModal({
    super.key,
    required this.event,
    required this.eventKey,
    required this.isActiveSession,
    this.activeIcon,
    this.activeTaskName,
    required this.onSessionStarted,
    required this.onSessionEnded,
  });

  static void show(
    BuildContext context, {
    required AssigmentModel event,
    required String eventKey,
    required bool isActiveSession,
    IconData? activeIcon,
    String? activeTaskName,
    required Function(String, IconData, String) onSessionStarted,
    required Function(String) onSessionEnded,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => EventActionModal(
        event: event,
        eventKey: eventKey,
        isActiveSession: isActiveSession,
        activeIcon: activeIcon,
        activeTaskName: activeTaskName,
        onSessionStarted: onSessionStarted,
        onSessionEnded: onSessionEnded,
      ),
    );
  }

  @override
  State<EventActionModal> createState() => _EventActionModalState();
}

class _EventActionModalState extends State<EventActionModal> {
  final EventsProvider _eventsService = EventsProvider();
  bool _isLoading = false;

  void _showCustomSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    CustomSnackBar.show(context, message, isError: isError);
  }

  Future<void> _onActivitySelected(String title, IconData icon) async {
    setState(() => _isLoading = true);

    try {
      final task = EventsProvider.taskFromTitle(title);
      await _eventsService.startAttendance(
        assignment: widget.event,
        task: task,
      );

      if (mounted) {
        widget.onSessionStarted(widget.eventKey, icon, title);
        Navigator.pop(context);
        _showCustomSnackBar('Participando: $title', isError: false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onExitSelected() async {
    final taskName = widget.activeTaskName ?? '';
    final currentTask = EventsProvider.taskFromTitle(taskName);

    // 1. SI ES SERVICIO -> Formulario de Servicio
    if (widget.activeIcon == Icons.construction ||
        currentTask == TaskType.service) {
      Navigator.pop(context); // Cierra este modal

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceExitFormScreen(
            event: widget.event,
            eventKey: widget.eventKey,
          ),
        ),
      );

      if (result == true) {
        widget.onSessionEnded(widget.eventKey);
        _showCustomSnackBar('Salida de Servicio registrada', isError: false);
      }
      return;
    }

    // 2. SI ES OFICINA O TALLER -> Modal de Reporte de Salida
    if (currentTask == TaskType.office || currentTask == TaskType.workshop) {
      Navigator.pop(context); // Cierra este modal

      final result = await showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E1E1E),
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => OfficeWorkshopExitModal(
          event: widget.event,
          task: currentTask,
          eventKey: widget.eventKey,
        ),
      );

      if (result == true) {
        widget.onSessionEnded(widget.eventKey);
        _showCustomSnackBar('Salida de ${currentTask.label} registrada',
            isError: false);
      }
      return;
    }

    // 3. RESTO (Transporte o genérico) -> Salida directa
    setState(() => _isLoading = true);

    try {
      final sid = widget.event.serverId;
      if (sid != null) {
        await _eventsService.endAttendance(serverId: sid);
        widget.onSessionEnded(widget.eventKey);
      }

      if (mounted) {
        Navigator.pop(context);
        _showCustomSnackBar('Salida registrada', isError: false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      child: SingleChildScrollView(
        child: _isLoading
            ? const SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF4CAF50)),
                      SizedBox(height: 16),
                      Text("Procesando...",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              )
            : widget.isActiveSession
                ? _buildExitSessionContent()
                : _buildStartSessionContent(),
      ),
    );
  }

  Widget _buildStartSessionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Iniciar Turno',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ActionOption(
          icon: Icons.business,
          title: 'Oficina',
          subtitle: 'Reuniones / Administrativo',
          onTap: () => _onActivitySelected('Oficina', Icons.business),
        ),
        ActionOption(
          icon: Icons.build,
          title: 'Taller',
          subtitle: 'Reparaciones',
          onTap: () => _onActivitySelected('Taller', Icons.build),
        ),
        ActionOption(
          icon: Icons.local_shipping,
          title: 'Transporte',
          subtitle: 'Traslados',
          onTap: () => _onActivitySelected('Transporte', Icons.local_shipping),
        ),
        ActionOption(
          icon: Icons.construction,
          title: 'Servicio',
          subtitle: 'Visitas técnicas',
          onTap: () => _onActivitySelected('Servicio', Icons.construction),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildExitSessionContent() {
    final activeIcon = widget.activeIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gestionar Turno',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Puedes cambiar tu actividad actual o finalizar el turno.',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 20),
        const Text(
          'CAMBIAR ACTIVIDAD',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        if (activeIcon != Icons.business)
          ActionOption(
            icon: Icons.business,
            title: 'Oficina',
            subtitle: 'Reuniones / Administrativo',
            onTap: () => _onActivitySelected('Oficina', Icons.business),
          ),
        if (activeIcon != Icons.build)
          ActionOption(
            icon: Icons.build,
            title: 'Taller',
            subtitle: 'Reparaciones',
            onTap: () => _onActivitySelected('Taller', Icons.build),
          ),
        if (activeIcon != Icons.local_shipping)
          ActionOption(
            icon: Icons.local_shipping,
            title: 'Transporte',
            subtitle: 'Traslados',
            onTap: () =>
                _onActivitySelected('Transporte', Icons.local_shipping),
          ),
        if (activeIcon != Icons.construction)
          ActionOption(
            icon: Icons.construction,
            title: 'Servicio',
            subtitle: 'Visitas técnicas',
            onTap: () => _onActivitySelected('Servicio', Icons.construction),
          ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.assignment),
                label: const Text("REPORTE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C).withOpacity(0.5),
                  foregroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                onPressed: () {
                  // Bloqueado temporalmente
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("SALIDA"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF5350),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _onExitSelected,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
