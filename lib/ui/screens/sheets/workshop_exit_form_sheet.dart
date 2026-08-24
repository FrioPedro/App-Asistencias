import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';
import '../../../core/permission_guard.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../../../core/picker_localization.dart';
import '../../../models/assigment_model.dart';
import '../../../models/taskType_model.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/report_form_provider.dart';
import '../../../providers/log_provider.dart';
import '../../../models/log_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/form_text_field.dart';
import '../../../models/activity/photo_item.dart';
import '../photo_caption_screen.dart';
import '../../widgets/photo_strip.dart';

class WorkshopExitFormScreen extends StatefulWidget {
  final AssigmentModel event;
  final String eventKey;
  final TaskType task;

  const WorkshopExitFormScreen({
    super.key,
    required this.event,
    required this.eventKey,
    required this.task,
  });

  @override
  State<WorkshopExitFormScreen> createState() => _WorkshopExitFormScreenState();
}

class _WorkshopExitFormScreenState extends State<WorkshopExitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  final AttendanceProvider _eventsService = AttendanceProvider();

  bool _isSubmitting = false;
  bool _submitAttempted = false;
  double _uploadProgress = 0.0;

  List<PhotoItem> _photos = [];

  static const int _maxPhotos = 20;

  // Colores de la app

  @override
  void dispose() {
    _notesController.dispose();
    for (final item in _photos) {
      item.dispose();
    }
    super.dispose();
  }

  /// Tema personalizado para el picker de fotos
  AssetPickerConfig _buildPickerConfig(int maxAssets) {
    return AssetPickerConfig(
      maxAssets: maxAssets,
      selectedAssets: [],
      requestType: RequestType.image,
      textDelegate: SpanishAssetPickerTextDelegate(
        compact: MediaQuery.textScalerOf(context).scale(14) > 18,
      ),
      pickerTheme: ThemeData.dark().copyWith(
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
      ),
    );
  }

  /// Tema personalizado para el picker de cámara
  CameraPickerConfig _buildCameraConfig() {
    return CameraPickerConfig(
      enableRecording: false,
      shouldDeletePreviewFile: true,
      textDelegate: const SpanishCameraPickerTextDelegate(),
      theme: ThemeData.dark().copyWith(
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primary,
          surface: AppColors.surface,
          background: AppColors.bg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bg,
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }

  /// Solicita permisos de fotos
  Future<bool> _requestPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (ps.isAuth || ps.hasAccess) {
      return true;
    }

    if (mounted) {
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: const Text(
            'Permisos requeridos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Se necesitan permisos para acceder a las fotos. '
            '¿Desea abrir la configuración para otorgar los permisos?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: const Text('Abrir Configuración'),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await PhotoManager.openSetting();
      }
    }
    return false;
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;

    setState(() => _submitAttempted = true);

    final formValid = _formKey.currentState!.validate();
    final photosValid = _photos.isNotEmpty;
    final captionsValid = _pendingCaptions == 0;

    if (!formValid || !photosValid || !captionsValid) {
      LogProvider.log(
        'Intento de envío de formulario de taller fallido: Campos obligatorios incompletos',
        type: LogType.warning,
        origin: 'WorkshopExitFormScreen',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0.0;
    });

    try {
      setState(() => _uploadProgress = 0.3);

      // Llamada al provider refactorizado
      final uploadSuccess = await WorkshopExitAsNotes.saveAll(
        sid: widget.event.serverId,
        taskType: widget.task,
        notes: _notesController.text,
        photos: _photos.map((p) => p.asset).toList(),
        descripciones: _photos.map((p) => p.caption.text).toList(),
      );

      if (!uploadSuccess && mounted) {
        CustomSnackBar.show(
            context, 'Error al subir los datos. Intente nuevamente.',
            isError: true);
        setState(() => _isSubmitting = false);
        return;
      }

      setState(() => _uploadProgress = 0.7);

      final sid = widget.eventKey;
      await _eventsService.endAttendance(keyGroup: sid);

      setState(() => _uploadProgress = 1.0);

      if (mounted) {
        LogProvider.log(
          'Formulario de Taller subido para OT: ${widget.event.documentId}',
          type: LogType.info,
          origin: 'WorkshopExitFormScreen',
        );
        CustomSnackBar.show(context, 'Taller finalizado correctamente',
            isError: false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, 'Error al finalizar: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Muestra opciones para agregar fotos (galería o cámara)
  Future<void> _showPhotoOptions() async {
    final currentPhotos = _photos;
    FocusScope.of(context).unfocus();

    final remaining = _maxPhotos - currentPhotos.length;

    if (remaining <= 0) {
      CustomSnackBar.show(context, 'Máximo $_maxPhotos fotos permitidas',
          isError: true);
      return;
    }

    if (!mounted) return;

    // Verificar estado actual de permisos
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!mounted) return;

    final bool isLimited = ps == PermissionState.limited;

    // Obtenemos la acción del bottom sheet
    final String? action = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xl, horizontal: AppSpacing.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
              ),
              const Text(
                'Agregar fotos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Puedes agregar hasta $remaining fotos más',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.xl),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildOptionButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Galería',
                        onTap: () => Navigator.pop(context, 'gallery'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildOptionButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Cámara',
                        onTap: () => Navigator.pop(context, 'camera'),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLimited) ...[
                const SizedBox(height: AppSpacing.xxl),
                const SizedBox(height: AppSpacing.lg),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, 'settings'),
                  icon: const Icon(Icons.settings, color: Colors.blueAccent),
                  label: const Text(
                    'Gestionar acceso a fotos (Limitado)',
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );

    if (action == 'gallery') {
      final hasGalleryAccess = await _requestPermission();
      if (hasGalleryAccess) {
        await Future.delayed(const Duration(milliseconds: 200));
        await _pickFromGallery(maxAssets: remaining);
      }
    } else if (action == 'camera') {
      if (!mounted) return;

      final hasCameraAccess =
          await PermissionGuard.checkCameraPermission(context);
      if (hasCameraAccess) {
        await Future.delayed(const Duration(milliseconds: 200));
        await _pickFromCamera();
      }
    } else if (action == 'settings') {
      await PhotoManager.openSetting();
    }
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xl, horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seleccionar fotos de la galería
  Future<void> _pickFromGallery({required int maxAssets}) async {
    try {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: _buildPickerConfig(maxAssets),
      );

      if (result != null && result.isNotEmpty) {
        LogProvider.log(
          '${result.length} foto(s) añadidas desde Galería',
          type: LogType.info,
          origin: 'WorkshopExitFormScreen',
        );
        setState(() {
          // Se recorta ANTES de construir los PhotoItem: si se descartaran
          // después, sus TextEditingController quedarían sin liberar.
          final espacio = _maxPhotos - _photos.length;
          _photos = [..._photos, ...result.take(espacio).map(PhotoItem.new)];
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, 'Error al abrir galería: $e',
            isError: true);
      }
    }
  }

  /// Tomar foto con la cámara
  Future<void> _pickFromCamera() async {
    try {
      final AssetEntity? result = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: _buildCameraConfig(),
      );

      if (result != null) {
        LogProvider.log(
          'Foto añadida desde Cámara',
          type: LogType.info,
          origin: 'WorkshopExitFormScreen',
        );
        setState(() {
          if (_photos.length < _maxPhotos) {
            _photos = [..._photos, PhotoItem(result)];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, 'Error al abrir cámara', isError: true);
      }
    }
  }

  void _removePhoto(PhotoItem item) {
    setState(() {
      _photos.remove(item);
    });
    // El controller vive en el PhotoItem, así que lo liberamos aquí.
    item.dispose();
  }

  /// Cuántas fotos siguen sin descripción válida.
  int get _pendingCaptions => _photos.where((p) => !p.isDescribed).length;

  /// Abre la vista de descripción. [startAt] permite entrar directo a una foto
  /// concreta al tocar su miniatura; si es nulo arranca en la primera pendiente.
  Future<void> _openCaptions({int? startAt}) async {
    if (_photos.isEmpty) return;

    final firstPending = _photos.indexWhere((p) => !p.isDescribed);
    FocusScope.of(context).unfocus();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoCaptionScreen(
          photos: _photos,
          sectionLabel: 'FOTOS',
          initialIndex: startAt ?? (firstPending == -1 ? 0 : firstPending),
          onRemove: _removePhoto,
        ),
      ),
    );

    // Al volver refrescamos los indicadores ✓ / pendiente.
    if (mounted) {
      FocusScope.of(context).unfocus();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
        title: const Text('Finalizar taller'),
      ),
      body: SafeArea(
        // Tocar fuera de un campo cierra el teclado. Con HitTestBehavior.opaque
        // el gesto cubre todo el área, pero los botones y campos hijos ganan la
        // arena de gestos, así que sus toques siguen funcionando igual.
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter, vertical: AppSpacing.lg),
            // Arrastrar la pantalla también cierra el teclado.
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormTextField(
                    label: '¿QUÉ HICISTE EN EL TALLER? (OBLIGATORIO)',
                    controller: _notesController,
                    hint: 'Describa las actividades realizadas...',
                    isRequired: true,
                    minChars: 30,
                    maxLines: 5,
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildPhotoSection(
                    label: 'FOTOS',
                    photos: _photos,
                    isRequired: true,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_isSubmitting)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: LinearProgressIndicator(
                              value: _uploadProgress,
                              backgroundColor: AppColors.surfaceRaised,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.success),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Subiendo ${_photos.length} fotos... ${(_uploadProgress * 100).toInt()}%',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  if (_pendingCaptions > 0 && !_isSubmitting)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppColors.warning, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _pendingCaptions == 1
                                  ? 'Falta la descripción de 1 foto'
                                  : 'Faltan las descripciones de '
                                      '$_pendingCaptions fotos',
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.ctaHeight,
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || _pendingCaptions > 0)
                          ? null
                          : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        disabledBackgroundColor: AppColors.disabled,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text.rich(
                              TextSpan(
                                children: [
                                  const WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right: AppSpacing.sm),
                                      child: Icon(Icons.check_circle_outline,
                                          color: Colors.white, size: 22),
                                    ),
                                  ),
                                  TextSpan(text: 'FINALIZAR (${_photos.length} fotos)'),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection({
    required String label,
    required List<PhotoItem> photos,
    bool isRequired = false,
  }) {
    final showMissingError = isRequired && photos.isEmpty && _submitAttempted;
    final pending = photos.where((p) => !p.isDescribed).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isRequired ? '$label (OBLIGATORIO)' : label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: photos.isEmpty
                    ? AppColors.surfaceRaised
                    : AppColors.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                '${photos.length}/$_maxPhotos',
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: photos.isEmpty
                      ? AppColors.textSecondary
                      : AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (photos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: PhotoStrip(
              photos: photos,
              onTapPhoto: _isSubmitting
                  ? null
                  : (index) => _openCaptions(startAt: index),
            ),
          ),
        if (photos.length < _maxPhotos && !_isSubmitting)
          GestureDetector(
            onTap: () => _showPhotoOptions(),
            child: Container(
              width: double.infinity,
              constraints:
                  const BoxConstraints(minHeight: AppSpacing.ctaHeight),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        margin: const EdgeInsets.only(right: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_a_photo_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                    ),
                    TextSpan(
                      text:
                          photos.isEmpty ? 'Agregar fotos' : 'Agregar más fotos',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        if (photos.isNotEmpty && !_isSubmitting) ...[
          const SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(
                minWidth: double.infinity, minHeight: AppSpacing.ctaHeight),
            child: OutlinedButton(
              onPressed: () => _openCaptions(),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    pending > 0 ? AppColors.warning : AppColors.success,
                side: BorderSide(
                    color: pending > 0 ? AppColors.warning : AppColors.success,
                    width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: Icon(
                          pending > 0
                              ? Icons.edit_note_rounded
                              : Icons.check_circle,
                          size: 24,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: pending > 0
                          ? 'DESCRIBIR FOTOS  ·  faltan $pending'
                          : 'DESCRIPCIONES LISTAS (${photos.length})',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        if (showMissingError && photos.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
            child: Text(
              '* Este campo es obligatorio',
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
