import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';
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
import '../overtime/overtime_request_form_screen.dart';

class AssigmentModal extends StatefulWidget {
  final AssigmentModel assignment;

  /// UI key (debe ser consistente con tu lista / maps). Ej: assignment.serverId.toString()
  final String eventKey;

  /// KeyGroup real de la sesión activa (para salida). Si no hay sesión activa, puede ser ''.
  final String keyGroup;

  final bool isActiveactivity;

  /// Hay un turno activo en cualquier proyecto, no necesariamente en este.
  final bool isAnyEventActive;

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
    this.isAnyEventActive = false,
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
    bool isAnyEventActive = false,
    IconData? activeIcon,
    String? activeTaskName,
    required void Function(
            String eventKey, String keyGroup, IconData icon, String taskName)
        onactivityStarted,
    required void Function(String eventKey) onactivityEnded,
  }) {
    print('[IS ANY EVENT ACTIVE]: $isAnyEventActive');
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.bg,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (context) => AssigmentModal(
        assignment: assignment,
        eventKey: eventKey,
        keyGroup: keyGroup,
        isActiveactivity: isActiveactivity,
        isAnyEventActive: isAnyEventActive,
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

  /// El sheet abre en el pre menu; el boton de turno pasa al contenido de
  /// siempre, que depende de si hay una actividad activa.
  bool _showShiftContent = false;

  void _showCustomSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    CustomSnackBar.show(context, message, isError: isError);
  }

  Future<void> _onActivitySelected(String title, IconData icon) async {
    final hasPermission =
        await PermissionGuard.checkLocationPermission(context);
    if (!hasPermission || !mounted) return;

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
              eventKey: widget.keyGroup,
              task: currentTask,
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
          useSafeArea: true,
          backgroundColor: AppColors.bg,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
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
              task: currentTask,
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
            eventKey: widget.keyGroup,
            task: currentTask,
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
        useSafeArea: true,
        backgroundColor: AppColors.bg,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
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
            task: currentTask,
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
                      CircularProgressIndicator(color: AppColors.success),
                      SizedBox(height: AppSpacing.lg),
                      Text("Procesando...",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              )
            : _showShiftContent
                ? (widget.isActiveactivity
                    ? _buildExitactivityContent()
                    : _buildStartactivityContent())
                : _buildPreMenu(),
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
                'Iniciar turno',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close,
                  color: AppColors.textSecondary, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ActionOption(
          icon: Icons.business,
          title: 'Oficina',
          onTap: () => _onActivitySelected('Oficina', Icons.business),
        ),
        ActionOption(
          icon: Icons.build,
          title: 'Taller',
          onTap: () => _onActivitySelected('Taller', Icons.build),
        ),
        ActionOption(
          icon: Icons.local_shipping,
          title: 'Transporte',
          onTap: () => _onActivitySelected('Transporte', Icons.local_shipping),
        ),
        ActionOption(
          icon: Icons.construction,
          title: 'Servicio',
          onTap: () => _onActivitySelected('Servicio', Icons.construction),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildPreMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Gestionar proyecto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close,
                  color: AppColors.textSecondary, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          (widget.isActiveactivity
              ? 'Puedes gestionar tu turno o solicitar horas extra.'
              : 'Puedes solicitar horas extra.'),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        if (!widget.isAnyEventActive || widget.isActiveactivity)
          _buildManageShiftButton(),
        const SizedBox(height: AppSpacing.xl),
        _buildOvertimeShortcut(),
      ],
    );
  }

  Widget _buildManageShiftButton() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(widget.isActiveactivity ? Icons.timer : Icons.login),
            label: Text(
                widget.isActiveactivity ? "Marcar horas" : "Iniciar turno"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: () => setState(() => _showShiftContent = true),
          ),
        ),
      ],
    );
  }

  Widget _buildExitactivityContent() {
    final activeIcon = widget.activeIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Gestionar turno',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close,
                  color: AppColors.textSecondary, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Puedes cambiar tu actividad actual o finalizar el turno.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (activeIcon != Icons.business)
          ActionOption(
            icon: Icons.business,
            title: 'Oficina',
            onTap: () => _onActivitySelected('Oficina', Icons.business),
          ),
        if (activeIcon != Icons.build)
          ActionOption(
            icon: Icons.build,
            title: 'Taller',
            onTap: () => _onActivitySelected('Taller', Icons.build),
          ),
        if (activeIcon != Icons.local_shipping)
          ActionOption(
            icon: Icons.local_shipping,
            title: 'Transporte',
            onTap: () =>
                _onActivitySelected('Transporte', Icons.local_shipping),
          ),
        if (activeIcon != Icons.construction)
          ActionOption(
            icon: Icons.construction,
            title: 'Servicio',
            onTap: () => _onActivitySelected('Servicio', Icons.construction),
          ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text("SALIDA"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: _onExitSelected,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildOvertimeShortcut() {
    final label = widget.assignment.description ?? widget.assignment.documentId;
    if (label == null || label.trim().isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceRaised,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.lg, horizontal: AppSpacing.lg),
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: _isLoading ? null : () => _openOvertimeForm(label),
            child: const Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(right: AppSpacing.xs),
                      child: Icon(Icons.bedtime_outlined,
                          color: AppColors.textSecondary, size: 14),
                    ),
                  ),
                  TextSpan(text: 'Solicitar horas extra'),
                ],
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Future<void> _openOvertimeForm(String label) async {
    final now = DateTime.now();

    // Sin hora de fin programada en la asignación, se sugiere la próxima media
    // hora; el operario la confirma en el formulario.
    final rounded = now.minute == 0 || now.minute == 30
        ? now
        : now.add(Duration(minutes: (now.minute < 30 ? 30 : 60) - now.minute));

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OvertimeRequestFormScreen(
          projectId: widget.assignment.serverId,
          initialDate: rounded,
          initialStartMinutes: rounded.hour * 60 + rounded.minute,
          contextLabel: label,
        ),
      ),
    );
  }
}
