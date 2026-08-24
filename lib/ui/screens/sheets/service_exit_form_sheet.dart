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
import '../../../models/activity/list_form_model.dart';
import '../../../models/activity/photo_item.dart';
import '../photo_caption_screen.dart';
import '../../widgets/photo_strip.dart';

class ServiceExitFormScreen extends StatefulWidget {
  final AssigmentModel event;
  final String eventKey;
  final TaskType task;

  const ServiceExitFormScreen({
    super.key,
    required this.event,
    required this.eventKey,
    required this.task,
  });

  @override
  State<ServiceExitFormScreen> createState() => _ServiceExitFormScreenState();
}

class _ServiceExitFormScreenState extends State<ServiceExitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incidenciasController = TextEditingController();
  final _conclusionesController = TextEditingController();
  final _recomendacionesController = TextEditingController();
  final _accionesController = TextEditingController();

  final AttendanceProvider _eventsService = AttendanceProvider();

  bool _isSubmitting = false;
  bool _submitAttempted = false;
  double _uploadProgress = 0.0;

  /// Un servicio de mantenimiento exige fotos ANTES y DESPUÉS, y habilita
  /// conclusiones y recomendaciones. Cualquier otro servicio lleva un solo
  /// grupo de fotos.
  bool _esMantenimiento = false;

  /// Cuando no es mantenimiento solo se usa [_photosAntes], que es el grupo
  /// único (se envía como `ListForm.foto_general`).
  List<PhotoItem> _photosAntes = [];
  List<PhotoItem> _photosDespues = [];

  static const int _maxPhotosPerSection = 20;

  // Colores de la app

  @override
  void dispose() {
    _incidenciasController.dispose();
    _conclusionesController.dispose();
    _recomendacionesController.dispose();
    _accionesController.dispose();
    for (final item in [..._photosAntes, ..._photosDespues]) {
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
      // Eliminamos themeColor porque causa conflicto si se usa pickerTheme simultáneamente
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
    final photosValid = _photosAntes.isNotEmpty &&
        (!_esMantenimiento || _photosDespues.isNotEmpty);
    final captionsValid = _pendingCaptions == 0;

    if (!formValid || !photosValid || !captionsValid) {
      LogProvider.log(
        'Intento de envío de formulario de servicio fallido: Campos obligatorios incompletos',
        type: LogType.warning,
        origin: 'ServiceExitFormScreen',
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
      final photoNoteType =
          _esMantenimiento ? ListForm.foto_antes : ListForm.foto_general;

      final uploadSuccess = await ServiceExitAsNotes.saveAll(
        sid: widget.event.serverId ?? 0,
        taskType: TaskType.service,
        incidencias: _esMantenimiento ? _incidenciasController.text : '',
        conclusiones: _esMantenimiento ? _conclusionesController.text : '',
        recomendaciones:
            _esMantenimiento ? _recomendacionesController.text : '',
        acciones: _accionesController.text,
        photosAntes: _photosAntes.map((p) => p.asset).toList(),
        descripcionesAntes: _photosAntes.map((p) => p.caption.text).toList(),
        photosDespues: _esMantenimiento
            ? (_photosDespues.map((p) => p.asset).toList())
            : [],
        descripcionesDespues: _esMantenimiento
            ? (_photosDespues.map((p) => p.caption.text).toList())
            : [],
        photoNoteType: photoNoteType,
      );

      if (!uploadSuccess && mounted) {
        CustomSnackBar.show(
            context, 'Error al subir las fotos. Intente nuevamente.',
            isError: true);
        setState(() => _isSubmitting = false);
        return;
      }

      // Las fotos DESPUÉS no se envían cuando no es mantenimiento: se
      // descartan aquí para no dejar basura en la galería del operario.
      if (!_esMantenimiento) {
        await _descartarFotosDespues();
      }

      setState(() => _uploadProgress = 0.7);

      final sid = widget.eventKey;
      if (sid != null) {
        await _eventsService.endAttendance(keyGroup: sid);
      }

      setState(() => _uploadProgress = 1.0);

      if (mounted) {
        LogProvider.log(
          'Formulario de Servicio subido para OT: ${widget.event.documentId}',
          type: LogType.info,
          origin: 'ServiceExitFormScreen',
        );
        CustomSnackBar.show(context, 'Servicio finalizado correctamente',
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
  Future<void> _showPhotoOptions({required bool isAntes}) async {
    final currentPhotos = isAntes ? _photosAntes : _photosDespues;
    FocusScope.of(context).unfocus();

    final remaining = _maxPhotosPerSection - currentPhotos.length;

    if (remaining <= 0) {
      CustomSnackBar.show(
          context, 'Máximo $_maxPhotosPerSection fotos permitidas',
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
              Text(
                isAntes ? 'Agregar fotos ANTES' : 'Agregar fotos DESPUÉS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Puedes agregar hasta $remaining fotos más',
                textAlign: TextAlign.center,
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
      // Para galería usamos PhotoManager (lógica existente)
      final hasGalleryAccess = await _requestPermission();
      if (hasGalleryAccess) {
        await Future.delayed(const Duration(milliseconds: 200));
        await _pickFromGallery(isAntes: isAntes, maxAssets: remaining);
      }
    } else if (action == 'camera') {
      // Para cámara usamos el nuevo PermissionGuard
      if (!mounted) return;

      final hasCameraAccess =
          await PermissionGuard.checkCameraPermission(context);
      if (hasCameraAccess) {
        await Future.delayed(const Duration(milliseconds: 200));
        await _pickFromCamera(isAntes: isAntes);
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
  Future<void> _pickFromGallery(
      {required bool isAntes, required int maxAssets}) async {
    debugPrint(
        'DEBUG: _pickFromGallery iniciado. isAntes: $isAntes, maxAssets: $maxAssets');
    try {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: _buildPickerConfig(maxAssets),
      );

      debugPrint(
          'DEBUG: Resultado del picker: ${result?.length ?? 0} fotos seleccionadas');

      if (result != null && result.isNotEmpty) {
        LogProvider.log(
          '${result.length} foto(s) añadidas desde Galería (${isAntes ? "Antes" : "Después"})',
          type: LogType.info,
          origin: 'ServiceExitFormScreen',
        );
        setState(() {
          final destino = isAntes ? _photosAntes : _photosDespues;
          final espacio = _maxPhotosPerSection - destino.length;
          final nuevos = result.take(espacio).map(PhotoItem.new);

          if (isAntes) {
            _photosAntes = [..._photosAntes, ...nuevos];
          } else {
            _photosDespues = [..._photosDespues, ...nuevos];
          }
        });
      }
    } catch (e) {
      debugPrint('Error crítico al abrir galería: $e');
      if (mounted) {
        CustomSnackBar.show(context, 'Error al abrir galería: $e',
            isError: true);
      }
    }
  }

  /// Tomar foto con la cámara
  Future<void> _pickFromCamera({required bool isAntes}) async {
    try {
      final AssetEntity? result = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: _buildCameraConfig(),
      );

      if (result != null) {
        LogProvider.log(
          'Foto añadida desde Cámara (${isAntes ? "Antes" : "Después"})',
          type: LogType.info,
          origin: 'ServiceExitFormScreen',
        );
        setState(() {
          if (isAntes) {
            if (_photosAntes.length < _maxPhotosPerSection) {
              _photosAntes = [
                ..._photosAntes,
                PhotoItem(result, fromCamera: true)
              ];
            }
          } else {
            if (_photosDespues.length < _maxPhotosPerSection) {
              _photosDespues = [
                ..._photosDespues,
                PhotoItem(result, fromCamera: true)
              ];
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error al abrir cámara: $e');
      if (mounted) {
        CustomSnackBar.show(context, 'Error al abrir cámara', isError: true);
      }
    }
  }

  /// Descarta el grupo DESPUÉS cuando el servicio no es mantenimiento y por lo
  /// tanto esas fotos no se subieron.
  ///
  /// Solo se borran del dispositivo las tomadas con la cámara de la app: las
  /// elegidas de la galería ya eran del operario y no se tocan. También se
  /// excluye cualquier asset que además esté en ANTES, porque ese sí se subió.
  ///
  /// Nunca interrumpe la finalización: si el borrado falla (el sistema puede
  /// pedir confirmación y el operario puede rechazarla) solo queda registrado
  /// en el log, porque el formulario ya se envió correctamente.
  Future<void> _descartarFotosDespues() async {
    if (_photosDespues.isEmpty) return;

    final descartados = _photosDespues;
    final idsAntes = _photosAntes.map((p) => p.asset.id).toSet();
    final idsABorrar = descartados
        .where((p) => p.fromCamera && !idsAntes.contains(p.asset.id))
        .map((p) => p.asset.id)
        .toList();

    // Primero se sueltan las referencias en memoria, para que la UI no vuelva
    // a pintar miniaturas de assets que están por desaparecer.
    if (mounted) {
      setState(() => _photosDespues = []);
    } else {
      _photosDespues = [];
    }
    for (final item in descartados) {
      item.dispose();
    }

    if (idsABorrar.isEmpty) return;

    try {
      final borrados = await PhotoManager.editor.deleteWithIds(idsABorrar);
      LogProvider.log(
        'Fotos DESPUÉS descartadas de la galería: '
        '${borrados.length} de ${idsABorrar.length}',
        type: borrados.length == idsABorrar.length
            ? LogType.info
            : LogType.warning,
        origin: 'ServiceExitFormScreen',
      );
    } catch (e) {
      LogProvider.log(
        'No se pudieron borrar las fotos DESPUÉS descartadas: $e',
        type: LogType.error,
        origin: 'ServiceExitFormScreen',
      );
    }
  }

  void _removePhoto(PhotoItem item, {required bool isAntes}) {
    setState(() {
      if (isAntes) {
        _photosAntes.remove(item);
      } else {
        _photosDespues.remove(item);
      }
    });
    // El controller vive en el PhotoItem, así que lo liberamos aquí.
    item.dispose();
  }

  List<PhotoItem> get _allPhotos =>
      _esMantenimiento ? [..._photosAntes, ..._photosDespues] : _photosAntes;

  /// Cuántas fotos siguen sin descripción válida.
  int get _pendingCaptions => _allPhotos.where((p) => !p.isDescribed).length;

  /// Etiqueta de la sección tal como la ve el operario.
  String _sectionLabel({required bool isAntes}) {
    if (!_esMantenimiento) return 'FOTOS';
    return isAntes ? 'ANTES' : 'DESPUÉS';
  }

  /// Abre la vista de descripción. [startAt] permite entrar directo a una foto
  /// concreta al tocar su miniatura; si es nulo arranca en la primera pendiente.
  Future<void> _openCaptions({required bool isAntes, int? startAt}) async {
    final photos = isAntes ? _photosAntes : _photosDespues;
    if (photos.isEmpty) return;

    final firstPending = photos.indexWhere((p) => !p.isDescribed);
    FocusScope.of(context).unfocus();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoCaptionScreen(
          photos: photos,
          sectionLabel: _sectionLabel(isAntes: isAntes),
          initialIndex: startAt ?? (firstPending == -1 ? 0 : firstPending),
          onRemove: (item) => _removePhoto(item, isAntes: isAntes),
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
        title: const Text('Finalizar servicio'),
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
                    label: '¿QUÉ HICISTE EN EL SERVICIO? (OBLIGATORIO)',
                    controller: _accionesController,
                    hint: 'Describa las acciones realizadas...',
                    isRequired: true,
                    minChars: 30,
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildMantenimientoToggle(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildPhotoSection(
                    label: _esMantenimiento ? 'FOTOS ANTES' : 'FOTOS',
                    photos: _photosAntes,
                    isAntes: true,
                    isRequired: true,
                  ),
                  if (_esMantenimiento) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _buildPhotoSection(
                      label: 'FOTOS DESPUÉS',
                      photos: _photosDespues,
                      isAntes: false,
                      isRequired: true,
                    ),
                  ],
                  if (_esMantenimiento) ...[
                    const SizedBox(height: AppSpacing.xl),
                    FormTextField(
                      label: 'INCIDENCIAS',
                      controller: _incidenciasController,
                      hint: 'Describa las incidencias encontradas...',
                      isRequired: false,
                      enabled: !_isSubmitting,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FormTextField(
                      label: 'CONCLUSIONES',
                      controller: _conclusionesController,
                      hint: 'Conclusiones del servicio...',
                      isRequired: false,
                      enabled: !_isSubmitting,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FormTextField(
                      label: 'RECOMENDACIONES',
                      controller: _recomendacionesController,
                      hint: 'Recomendaciones para el cliente...',
                      isRequired: false,
                      enabled: !_isSubmitting,
                    ),
                  ],
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
                            'Subiendo ${_allPhotos.length} fotos... ${(_uploadProgress * 100).toInt()}%',
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
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || _pendingCaptions > 0)
                          ? null
                          : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
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
                                          right: AppSpacing.xs),
                                      child: Icon(Icons.check_circle_outline,
                                          color: Colors.white, size: 14),
                                    ),
                                  ),
                                  TextSpan(text: 'FINALIZAR (${_allPhotos.length} fotos)'),
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

  /// Toggle que define la forma del formulario: mantenimiento = fotos ANTES y
  /// DESPUÉS + conclusiones y recomendaciones; cualquier otro servicio = un
  /// solo grupo de fotos.
  Widget _buildMantenimientoToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: SwitchListTile(
        value: _esMantenimiento,
        onChanged: _isSubmitting
            ? null
            : (value) => setState(() => _esMantenimiento = value),
        contentPadding: EdgeInsets.zero,
        activeColor: Colors.white,
        activeTrackColor: AppColors.primary,
        title: const Text(
          '¿ES MANTENIMIENTO?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: Text(
          _esMantenimiento
              ? 'Pide fotos de antes y después del trabajo'
              : 'Pide un solo grupo de fotos',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildPhotoSection({
    required String label,
    required List<PhotoItem> photos,
    required bool isAntes,
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
                '${photos.length}/$_maxPhotosPerSection',
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
                  : (index) => _openCaptions(isAntes: isAntes, startAt: index),
            ),
          ),
        if (photos.length < _maxPhotosPerSection && !_isSubmitting)
          GestureDetector(
            onTap: () => _showPhotoOptions(isAntes: isAntes),
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
              onPressed: () => _openCaptions(isAntes: isAntes),
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
