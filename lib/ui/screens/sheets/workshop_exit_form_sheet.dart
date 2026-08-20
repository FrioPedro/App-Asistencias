import 'package:flutter/material.dart';
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
  static const Color _bgColor = Color(0xFF121212);
  static const Color _cardColor = Color(0xFF2C2C2C);
  static const Color _primaryBlue = Color(0xFF2E60C4);
  static const Color _exitRed = Color(0xFFEF5350);
  static const Color _pendingAmber = Color(0xFFFFB300);
  static const Color _okGreen = Color(0xFF4CAF50);

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
      textDelegate: const SpanishAssetPickerTextDelegate(),
      pickerTheme: ThemeData.dark().copyWith(
        primaryColor: _primaryBlue,
        colorScheme: const ColorScheme.dark(
          primary: _primaryBlue,
          surface: _cardColor,
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
        primaryColor: _primaryBlue,
        colorScheme: const ColorScheme.dark(
          primary: _primaryBlue,
          secondary: _primaryBlue,
          surface: _cardColor,
          background: _bgColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _bgColor,
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
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Permisos requeridos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Se necesitan permisos para acceder a las fotos. '
            '¿Desea abrir la configuración para otorgar los permisos?',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
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
              const SizedBox(height: 8),
              Text(
                'Puedes agregar hasta $remaining fotos más',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Galería',
                    onTap: () => Navigator.pop(context, 'gallery'),
                  ),
                  _buildOptionButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Cámara',
                    onTap: () => Navigator.pop(context, 'camera'),
                  ),
                ],
              ),
              if (isLimited) ...[
                const SizedBox(height: 32),
                const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _primaryBlue, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label,
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
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Finalizar taller',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        // Tocar fuera de un campo cierra el teclado. Con HitTestBehavior.opaque
        // el gesto cubre todo el área, pero los botones y campos hijos ganan la
        // arena de gestos, así que sus toques siguen funcionando igual.
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                  const SizedBox(height: 20),
                  _buildPhotoSection(
                    label: 'FOTOS',
                    photos: _photos,
                    isRequired: true,
                  ),
                  const SizedBox(height: 24),
                  if (_isSubmitting)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _uploadProgress,
                              backgroundColor: Colors.grey[800],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF4CAF50)),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Subiendo ${_photos.length} fotos... ${(_uploadProgress * 100).toInt()}%',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  if (_pendingCaptions > 0 && !_isSubmitting)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: _pendingAmber, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _pendingCaptions == 1
                                  ? 'Falta la descripción de 1 foto'
                                  : 'Faltan las descripciones de '
                                      '$_pendingCaptions fotos',
                              style: const TextStyle(
                                color: _pendingAmber,
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
                    height: 54,
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || _pendingCaptions > 0)
                          ? null
                          : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _exitRed,
                        disabledBackgroundColor: Colors.grey[700],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  'FINALIZAR (${_photos.length} fotos)',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
            Text(
              isRequired ? '$label (OBLIGATORIO)' : label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: photos.isEmpty
                    ? Colors.grey[800]
                    : _okGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${photos.length}/$_maxPhotos',
                style: TextStyle(
                  color: photos.isEmpty ? Colors.grey[500] : _okGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (photos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
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
              height: 56,
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_rounded,
                        color: _primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    photos.isEmpty ? 'Agregar fotos' : 'Agregar más fotos',
                    style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        if (photos.isNotEmpty && !_isSubmitting) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _openCaptions(),
              icon: Icon(
                pending > 0 ? Icons.edit_note_rounded : Icons.check_circle,
                size: 20,
              ),
              label: Text(
                pending > 0
                    ? 'DESCRIBIR FOTOS  ·  faltan $pending'
                    : 'DESCRIPCIONES LISTAS (${photos.length})',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: pending > 0 ? _pendingAmber : _okGreen,
                side: BorderSide(
                    color: pending > 0 ? _pendingAmber : _okGreen, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
        if (showMissingError && photos.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              '* Este campo es obligatorio',
              style: TextStyle(
                color: _exitRed,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
