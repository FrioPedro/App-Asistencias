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
  final _antesCaptionController = TextEditingController();
  final _despuesCaptionController = TextEditingController();

  final AttendanceProvider _eventsService = AttendanceProvider();

  bool _isSubmitting = false;
  bool _submitAttempted = false;
  double _uploadProgress = 0.0;

  // Listas separadas para fotos ANTES y DESPUÉS
  List<AssetEntity> _photosAntes = [];
  List<AssetEntity> _photosDespues = [];

  static const int _maxPhotosPerSection = 20;

  // Colores de la app
  static const Color _bgColor = Color(0xFF121212);
  static const Color _cardColor = Color(0xFF2C2C2C);
  static const Color _primaryBlue = Color(0xFF2E60C4);
  static const Color _exitRed = Color(0xFFEF5350);

  @override
  void dispose() {
    _notesController.dispose();
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
    final photosValid = _photosAntes.isNotEmpty && _photosDespues.isNotEmpty;

    if (!formValid || !photosValid) {
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
        descripcionAntes: _antesCaptionController.text,
        photosAntes: _photosAntes,
        photosDespues: _photosDespues,
        descripcionDespues: _despuesCaptionController.text,
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
  Future<void> _showPhotoOptions({required bool isAntes}) async {
    final currentPhotos = isAntes ? _photosAntes : _photosDespues;
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
              Text(
                isAntes ? 'Agregar fotos ANTES' : 'Agregar fotos DESPUÉS',
                style: const TextStyle(
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
        await _pickFromGallery(isAntes: isAntes, maxAssets: remaining);
      }
    } else if (action == 'camera') {
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
  Future<void> _pickFromGallery(
      {required bool isAntes, required int maxAssets}) async {
    try {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: _buildPickerConfig(maxAssets),
      );

      if (result != null && result.isNotEmpty) {
        LogProvider.log(
          '${result.length} foto(s) añadidas desde Galería (${isAntes ? "Antes" : "Después"})',
          type: LogType.info,
          origin: 'WorkshopExitFormScreen',
        );
        setState(() {
          if (isAntes) {
            _photosAntes = [..._photosAntes, ...result]
                .take(_maxPhotosPerSection)
                .toList();
          } else {
            _photosDespues = [..._photosDespues, ...result]
                .take(_maxPhotosPerSection)
                .toList();
          }
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
          origin: 'WorkshopExitFormScreen',
        );
        setState(() {
          if (isAntes) {
            if (_photosAntes.length < _maxPhotosPerSection) {
              _photosAntes = [..._photosAntes, result];
            }
          } else {
            if (_photosDespues.length < _maxPhotosPerSection) {
              _photosDespues = [..._photosDespues, result];
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, 'Error al abrir cámara', isError: true);
      }
    }
  }

  void _removePhoto(AssetEntity asset, {required bool isAntes}) {
    setState(() {
      if (isAntes) {
        _photosAntes.remove(asset);
      } else {
        _photosDespues.remove(asset);
      }
    });
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhotoSection(
                  label: 'FOTOS ANTES',
                  photos: _photosAntes,
                  isAntes: true,
                  isRequired: true,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: _buildFormField(
                    label: 'Descripción',
                    controller: _antesCaptionController,
                    hint: 'Describa las fotos antes del taller...',
                    maxLines: 1,
                    isRequired: true,
                  ),
                ),
                const SizedBox(height: 20),
                _buildPhotoSection(
                  label: 'FOTOS DESPUÉS',
                  photos: _photosDespues,
                  isAntes: false,
                  isRequired: true,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: _buildFormField(
                    label: 'Descripción',
                    controller: _despuesCaptionController,
                    hint: 'Describa las fotos después del taller...',
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 20),
                _buildFormField(
                  label: 'NOTAS (OBLIGATORIO)',
                  controller: _notesController,
                  hint: 'Describa las actividades realizadas...',
                  isRequired: true,
                  minChars: 50,
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
                          'Subiendo ${_photosAntes.length + _photosDespues.length} fotos... ${(_uploadProgress * 100).toInt()}%',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _onSubmit,
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
                                'FINALIZAR (${_photosAntes.length + _photosDespues.length} fotos)',
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
    );
  }

  Widget _buildPhotoSection({
    required String label,
    required List<AssetEntity> photos,
    required bool isAntes,
    bool isRequired = false,
  }) {
    final showMissingError =
        isRequired && photos.isEmpty && _submitAttempted;
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
                    : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${photos.length}/$_maxPhotosPerSection',
                style: TextStyle(
                  color: photos.isEmpty ? Colors.grey[500] : Colors.green[400],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (photos.isNotEmpty)
          Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final asset = photos[index];
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AssetEntityImage(
                          asset,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          isOriginal: false,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (!_isSubmitting)
                      Positioned(
                        top: -5,
                        right: -5,
                        child: GestureDetector(
                          onTap: () => _removePhoto(asset, isAntes: isAntes),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _exitRed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        if (photos.length < _maxPhotosPerSection && !_isSubmitting)
          GestureDetector(
            onTap: () => _showPhotoOptions(isAntes: isAntes),
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
                    child: Icon(Icons.add_a_photo_rounded,
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
        if (showMissingError)
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 20),
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

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isRequired = true,
    int maxLines = 5,
    int minChars = 0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextFormField(
            controller: controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            maxLines: maxLines,
            enabled: !_isSubmitting,
            validator: (v) {
              if (!isRequired) return null;
              if (v == null || v.trim().isEmpty) {
                return '* Este campo es obligatorio';
              } else if (v.length < minChars) {
                return '* Debes introducir $minChars caracteres como mínimo';
              } else {
                return null;
              }
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              border: InputBorder.none,
              errorStyle: const TextStyle(
                color: _exitRed,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 2.2,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
