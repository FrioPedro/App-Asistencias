import 'package:flutter/material.dart';
import '../../../core/permission_guard.dart';
import '../../../models/assigment_model.dart';
import '../../../providers/attendance_provider.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/action_option.dart';
import 'service_exit_form_sheet.dart';
import 'workshop_exit_form_sheet.dart';
import 'office_workshop_exit_sheet.dart';
import '../../../providers/log_provider.dart';
import '../../../models/log_model.dart';
import 'package:app_asistencias/models/taskType_model.dart';

class AssigmentModal extends StatefulWidget {
  final AssigmentModel assignment;

  /// UI key (debe ser consistente con tu lista / maps). Ej: assignment.serverId.toString()
  final String eventKey;

  /// KeyGroup real de la sesión activa (para salida). Si no hay sesión activa, puede ser ''.
  final String keyGroup;

  final bool isActiveactivity;
  final IconData? activeIcon;
  final String? activeTaskName;

  /// eventKey, keyGroup, icon, taskName
  final void Function(
          String eventKey, String keyGroup, IconData icon, String taskName)
      onactivityStarted;

  /// eventKey
  final void Function(String eventKey) onactivityEnded;

  const AssigmentModal({
    super.key,
    required this.assignment,
    required this.eventKey,
    required this.keyGroup,
    required this.isActiveactivity,
    this.activeIcon,
    this.activeTaskName,
    required this.onactivityStarted,
    required this.onactivityEnded,
  });

  static void show(
    BuildContext context, {
    required AssigmentModel assignment,
    required String eventKey,
    required String keyGroup,
    required bool isActiveactivity,
    IconData? activeIcon,
    String? activeTaskName,
    required void Function(
            String eventKey, String keyGroup, IconData icon, String taskName)
        onactivityStarted,
    required void Function(String eventKey) onactivityEnded,
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
      builder: (context) => AssigmentModal(
        assignment: assignment,
        eventKey: eventKey,
        keyGroup: keyGroup,
        isActiveactivity: isActiveactivity,
        activeIcon: activeIcon,
        activeTaskName: activeTaskName,
        onactivityStarted: onactivityStarted,
        onactivityEnded: onactivityEnded,
      ),
    );
  }

  @override
  State<AssigmentModal> createState() => _EventActionModalState();
}

class _EventActionModalState extends State<AssigmentModal> {
  final AttendanceProvider _attendanceService = AttendanceProvider();
  bool _isLoading = false;

  void _showCustomSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    CustomSnackBar.show(context, message, isError: isError);
  }

  Future<void> _onActivitySelected(String title, IconData icon) async {
    final hasPermission =
        await PermissionGuard.checkLocationPermission(context);
    if (!hasPermission) return;

    // --- Intercepción de formularios si hay actividad activa ---
    if (widget.isActiveactivity) {
      final currentTaskName = widget.activeTaskName ?? '';
      final currentTask = TaskTypeX.fromLabel(currentTaskName);

      // Caso 1: Servicio -> Formulario de servicio (usa keyGroup)
      if (widget.activeIcon == Icons.construction ||
          currentTask == TaskType.service) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceExitFormScreen(
              event: widget.assignment,
              eventKey:
                  widget.keyGroup, // aquí "eventKey" es keyGroup en tu screen
            ),
          ),
        );

        if (result != true) return;
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      // Caso 2: Oficina -> Modal de reporte (usa keyGroup)
      else if (currentTask == TaskType.office) {
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
            event: widget.assignment,
            task: currentTask,
            eventKey: widget.keyGroup,
          ),
        );

        if (result != true) return;
        await Future.delayed(const Duration(milliseconds: 1000));
      }
      // Caso 3: Taller -> Formulario Completo (usa keyGroup)
      else if (currentTask == TaskType.workshop) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkshopExitFormScreen(
              event: widget.assignment,
              eventKey: widget.keyGroup,
            ),
          ),
        );

        if (result != true) return;
        await Future.delayed(const Duration(milliseconds: 1000));
      }
      // Caso 3: Transporte u otros -> cambio directo
    }

    setState(() => _isLoading = true);

    try {
      final task = TaskTypeX.fromLabel(title);

      // IMPORTANTE: asumo que startAttendance devuelve el keyGroup creado
      final newKeyGroup = await _attendanceService.startAttendance(
        assignment: widget.assignment,
        task: task,
      );

      print(
          '[MODAL] startAttendance -> eventKey="${widget.eventKey}" newKeyGroup="$newKeyGroup"');

      if (!mounted) return;

      final actionType = widget.isActiveactivity ? 'Cambio' : 'Inicio';
      LogProvider.log(
        '$actionType de turno: $title (${widget.assignment.description})',
        type: widget.isActiveactivity ? LogType.warning : LogType.info,
        origin: 'EventActionModal',
      );

      // ✅ Notificamos al screen con el eventKey (UI) y el keyGroup real
      widget.onactivityStarted(widget.eventKey, newKeyGroup, icon, title);

      Navigator.pop(context);
      _showCustomSnackBar('Participando: $title', isError: false);
    } catch (e) {
      print('[MODAL] _onActivitySelected Exception: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onExitSelected() async {
    final taskName = widget.activeTaskName ?? '';
    final currentTask = TaskTypeX.fromLabel(taskName);

    print('--- EXIT SELECTED ---');
    print('[EXIT] eventKey(UI) = "${widget.eventKey}"');
    print('[EXIT] keyGroup(session) = "${widget.keyGroup}"');
    print('[EXIT] isActive = ${widget.isActiveactivity}');
    print(
        '[EXIT] activeTaskName="${widget.activeTaskName}" -> currentTask=${currentTask.label}');
    print('[EXIT] assignment.serverId=${widget.assignment.serverId}');
    print('[EXIT] assignment.documentId=${widget.assignment.documentId}');
    print('[EXIT] activeIcon=${widget.activeIcon}');
    print('---------------------');

    // 1) Servicio -> Formulario
    if (widget.activeIcon == Icons.construction ||
        currentTask == TaskType.service) {
      Navigator.pop(context);

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceExitFormScreen(
            event: widget.assignment,
            eventKey:
                widget.keyGroup, // en tu screen esto realmente es keyGroup
          ),
        ),
      );

      if (result == true) {
        widget.onactivityEnded(widget.eventKey);
        _showCustomSnackBar('Salida de Servicio registrada', isError: false);
      }
      return;
    }

    // 2) Oficina -> Modal reporte
    if (currentTask == TaskType.office) {
      Navigator.pop(context);

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
          event: widget.assignment,
          task: currentTask,
          eventKey: widget.keyGroup,
        ),
      );

      if (result == true) {
        widget.onactivityEnded(widget.eventKey);
        _showCustomSnackBar('Salida de Oficina registrada', isError: false);
      }
      return;
    }

    // 3) Taller -> Formulario Completo
    if (currentTask == TaskType.workshop) {
      Navigator.pop(context);

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkshopExitFormScreen(
            event: widget.assignment,
            eventKey: widget.keyGroup,
          ),
        ),
      );

      if (result == true) {
        widget.onactivityEnded(widget.eventKey);
        _showCustomSnackBar('Salida de Taller registrada', isError: false);
      }
      return;
    }

    // 3) Directo
    setState(() => _isLoading = true);

    try {
      if (widget.keyGroup.trim().isEmpty) {
        _showCustomSnackBar('KeyGroup vacío. Refresca la pantalla.',
            isError: true);
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      await _attendanceService.endAttendance(keyGroup: widget.keyGroup);

      // ✅ Notificamos al screen por eventKey (UI), NO por keyGroup
      widget.onactivityEnded(widget.eventKey);

      if (!mounted) return;

      LogProvider.log(
        'Salida directa registrada: ${widget.assignment.description}',
        type: LogType.warning,
        origin: 'EventActionModal',
      );

      Navigator.pop(context);
      _showCustomSnackBar('Salida registrada', isError: false);
    } catch (e) {
      print('[MODAL] _onExitSelected Exception: $e');
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
            : widget.isActiveactivity
                ? _buildExitactivityContent()
                : _buildStartactivityContent(),
      ),
    );
  }

  Widget _buildStartactivityContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                'Iniciar Turno',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey, size: 28),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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

  Widget _buildExitactivityContent() {
    final activeIcon = widget.activeIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                'Gestionar Turno',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey, size: 28),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text("SALIDA"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _onExitSelected,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
