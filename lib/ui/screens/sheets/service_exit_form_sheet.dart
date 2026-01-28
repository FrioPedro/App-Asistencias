import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import '../../../core/enpoinService.dart';
import '../../../models/assigment_model.dart';
import '../../../providers/events_provider.dart';
import '../../widgets/custom_snackbar.dart';

class ServiceExitFormScreen extends StatefulWidget {
  final AssigmentModel event;
  final String eventKey;

  const ServiceExitFormScreen({
    super.key,
    required this.event,
    required this.eventKey,
  });

  @override
  State<ServiceExitFormScreen> createState() => _ServiceExitFormScreenState();
}

class _ServiceExitFormScreenState extends State<ServiceExitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incidenciasController = TextEditingController();
  final _conclusionesController = TextEditingController();
  final _recomendacionesController = TextEditingController();

  final EventsProvider _eventsService = EventsProvider();
  final EndpointService _api = EndpointService.instance;

  bool _isSubmitting = false;
  double _uploadProgress = 0.0;

  // Listas separadas para fotos ANTES y DESPUÉS
  List<AssetEntity> _photosAntes = [];
  List<AssetEntity> _photosDespues = [];

  static const int _maxPhotosPerSection = 20;

  @override
  void dispose() {
    _incidenciasController.dispose();
    _conclusionesController.dispose();
    _recomendacionesController.dispose();
    super.dispose();
  }

  /// Convierte AssetEntity a File
  Future<File?> _assetToFile(AssetEntity asset) async {
    return await asset.file;
  }

  /// Solicita permisos de fotos
  Future<bool> _requestPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    // Permitir si tiene acceso completo o limitado
    if (ps.isAuth || ps.hasAccess) {
      return true;
    }

    // Si el permiso fue denegado permanentemente, ofrecer abrir configuración
    if (mounted) {
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text(
            'Permisos requeridos',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Se necesitan permisos para acceder a las fotos. '
            '¿Desea abrir la configuración para otorgar los permisos?',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
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

  /// Sube las fotos al servidor
  Future<bool> _uploadPhotos() async {
    try {
      // Convertir AssetEntity a Files
      final antesFiles = <File>[];
      final despuesFiles = <File>[];

      for (final asset in _photosAntes) {
        final file = await _assetToFile(asset);
        if (file != null) antesFiles.add(file);
      }

      for (final asset in _photosDespues) {
        final file = await _assetToFile(asset);
        if (file != null) despuesFiles.add(file);
      }

      // Crear FormData con todas las fotos y datos del formulario
      final formData = FormData();

      // Agregar ID del servicio
      formData.fields
          .add(MapEntry('serverId', widget.event.serverId.toString()));
      formData.fields
          .add(MapEntry('incidencias', _incidenciasController.text.trim()));
      formData.fields
          .add(MapEntry('conclusiones', _conclusionesController.text.trim()));
      formData.fields.add(
          MapEntry('recomendaciones', _recomendacionesController.text.trim()));

      // Agregar fotos ANTES
      for (int i = 0; i < antesFiles.length; i++) {
        final file = antesFiles[i];
        formData.files.add(MapEntry(
          'fotos_antes',
          await MultipartFile.fromFile(
            file.path,
            filename:
                'antes_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      }

      // Agregar fotos DESPUÉS
      for (int i = 0; i < despuesFiles.length; i++) {
        final file = despuesFiles[i];
        formData.files.add(MapEntry(
          'fotos_despues',
          await MultipartFile.fromFile(
            file.path,
            filename:
                'despues_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      }

      // Enviar al servidor
      final response = await _api.postFormData(
        '/api/servicios/reporte',
        formData: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
            'Error en subida: ${response.statusCode} - ${response.data}');
        return false;
      }
    } catch (e) {
      debugPrint('Error al subir fotos: $e');
      return false;
    }
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    // Validar que haya al menos una foto en cada sección
    if (_photosAntes.isEmpty) {
      CustomSnackBar.show(context, 'Debe agregar al menos una foto ANTES',
          isError: true);
      return;
    }
    if (_photosDespues.isEmpty) {
      CustomSnackBar.show(context, 'Debe agregar al menos una foto DESPUÉS',
          isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0.0;
    });

    try {
      // 1. Subir fotos y datos del formulario
      setState(() => _uploadProgress = 0.3);
      final uploadSuccess = await _uploadPhotos();

      if (!uploadSuccess && mounted) {
        CustomSnackBar.show(
            context, 'Error al subir las fotos. Intente nuevamente.',
            isError: true);
        setState(() => _isSubmitting = false);
        return;
      }

      setState(() => _uploadProgress = 0.7);

      // 2. Finalizar la asistencia
      final sid = widget.event.serverId;
      if (sid != null) {
        await _eventsService.endAttendance(serverId: sid);
      }

      setState(() => _uploadProgress = 1.0);

      if (mounted) {
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

  Future<void> _pickPhotos({required bool isAntes}) async {
    // Primero solicitar permisos
    final hasPermission = await _requestPermission();
    if (!hasPermission) return;

    final currentPhotos = isAntes ? _photosAntes : _photosDespues;
    final remaining = _maxPhotosPerSection - currentPhotos.length;

    if (remaining <= 0) {
      CustomSnackBar.show(
          context, 'Máximo $_maxPhotosPerSection fotos permitidas',
          isError: true);
      return;
    }

    try {
      final AssetPickerConfig pickerConfig = AssetPickerConfig(
        maxAssets: remaining,
        selectedAssets: [],
        requestType: RequestType.image,
        specialPickerType: SpecialPickerType.noPreview,
        specialItemPosition: SpecialItemPosition.prepend,
        specialItemBuilder: (context, path, length) {
          return GestureDetector(
            onTap: () async {
              try {
                final AssetEntity? result = await CameraPicker.pickFromCamera(
                  context,
                  pickerConfig: const CameraPickerConfig(
                    enableRecording: false,
                    shouldDeletePreviewFile: true,
                  ),
                );
                if (result != null && mounted) {
                  Navigator.pop(context, [result]);
                }
              } catch (e) {
                debugPrint('Error al abrir cámara: $e');
              }
            },
            child: Container(
              color: Colors.grey[900],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white, size: 30),
                  SizedBox(height: 4),
                  Text("Cámara",
                      style: TextStyle(color: Colors.white, fontSize: 12))
                ],
              ),
            ),
          );
        },
      );

      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: pickerConfig,
      );

      if (result != null && result.isNotEmpty) {
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
      debugPrint('Error al abrir picker: $e');
      if (mounted) {
        CustomSnackBar.show(context, 'Error al abrir selector de fotos: $e',
            isError: true);
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
    const bg = Color(0xFF121212);
    const cardColor = Color(0xFF2C2C2C);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Finalizar Servicio',
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
                // Sección ANTES
                _buildPhotoSection(
                  label: 'FOTOS ANTES',
                  photos: _photosAntes,
                  isAntes: true,
                  cardColor: cardColor,
                ),
                const SizedBox(height: 16),

                // Sección DESPUÉS
                _buildPhotoSection(
                  label: 'FOTOS DESPUÉS',
                  photos: _photosDespues,
                  isAntes: false,
                  cardColor: cardColor,
                ),
                const SizedBox(height: 16),

                _buildFormField(
                  label: 'INCIDENCIAS',
                  controller: _incidenciasController,
                  hint: 'Describa las incidencias encontradas...',
                  cardColor: cardColor,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  label: 'CONCLUSIONES',
                  controller: _conclusionesController,
                  hint: 'Conclusiones del servicio...',
                  cardColor: cardColor,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  label: 'RECOMENDACIONES',
                  controller: _recomendacionesController,
                  hint: 'Recomendaciones para el cliente...',
                  cardColor: cardColor,
                ),
                const SizedBox(height: 16),

                // Barra de progreso durante la subida
                if (_isSubmitting)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: _uploadProgress,
                          backgroundColor: Colors.grey[800],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4CAF50)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Subiendo fotos... ${(_uploadProgress * 100).toInt()}%',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFEF5350), // Rojo para salida
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'FINALIZAR SERVICIO (${_photosAntes.length + _photosDespues.length} fotos)',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
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
    required Color cardColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(label),
            Text(
              '${photos.length}/$_maxPhotosPerSection',
              style: TextStyle(
                color: photos.isEmpty ? Colors.grey[600] : Colors.green[400],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Grid de fotos seleccionadas
        if (photos.isNotEmpty)
          Container(
            height: 110,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final asset = photos[index];
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AssetEntityImage(
                        asset,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        isOriginal: false,
                      ),
                    ),
                    // Número de foto
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Botón eliminar
                    if (!_isSubmitting)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => _removePhoto(asset, isAntes: isAntes),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF5350),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4)
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

        // Botón para agregar fotos
        if (photos.length < _maxPhotosPerSection && !_isSubmitting)
          GestureDetector(
            onTap: () => _pickPhotos(isAntes: isAntes),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(
                    photos.isEmpty
                        ? "Subir Fotos (Máx $_maxPhotosPerSection)"
                        : "Agregar más fotos",
                    style: TextStyle(
                        color: Colors.grey[400], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required Color cardColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            enabled: !_isSubmitting,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Este campo es obligatorio'
                : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16.0),
            ),
          ),
        ),
      ],
    );
  }
}
