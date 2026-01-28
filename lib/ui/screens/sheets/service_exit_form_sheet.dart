import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
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

  bool _isSubmitting = false;

  // Listas separadas para fotos ANTES y DESPUÉS
  List<AssetEntity> _photosAntes = [];
  List<AssetEntity> _photosDespues = [];

  static const int _maxPhotosPerSection = 3;

  @override
  void dispose() {
    _incidenciasController.dispose();
    _conclusionesController.dispose();
    _recomendacionesController.dispose();
    super.dispose();
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

    setState(() => _isSubmitting = true);

    try {
      // 1. Convertir AssetEntity a archivos para subir
      // TODO: Implementar la lógica de subida de fotos al servidor
      // Ejemplo:
      // final antesFiles = await Future.wait(_photosAntes.map((e) => e.file));
      // final despuesFiles = await Future.wait(_photosDespues.map((e) => e.file));

      // 2. Simular envío (reemplazar con lógica real)
      await Future.delayed(const Duration(seconds: 1));

      // 3. Finalizar la asistencia
      final sid = widget.event.serverId;
      if (sid != null) {
        await _eventsService.endAttendance(serverId: sid);
      }

      if (mounted) {
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
    final currentPhotos = isAntes ? _photosAntes : _photosDespues;
    final remaining = _maxPhotosPerSection - currentPhotos.length;

    if (remaining <= 0) {
      CustomSnackBar.show(
          context, 'Máximo $_maxPhotosPerSection fotos permitidas',
          isError: true);
      return;
    }

    final AssetPickerConfig pickerConfig = AssetPickerConfig(
      maxAssets: remaining,
      selectedAssets: [],
      requestType: RequestType.image,
      specialPickerType: SpecialPickerType.noPreview,
      specialItemPosition: SpecialItemPosition.prepend,
      specialItemBuilder: (context, path, length) {
        return GestureDetector(
          onTap: () async {
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
          _photosAntes =
              [..._photosAntes, ...result].take(_maxPhotosPerSection).toList();
        } else {
          _photosDespues = [..._photosDespues, ...result]
              .take(_maxPhotosPerSection)
              .toList();
        }
      });
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
          onPressed: () => Navigator.pop(context),
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
                        : const Text(
                            'FINALIZAR SERVICIO',
                            style: TextStyle(
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
        _buildSectionTitle(label),
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
        if (photos.length < _maxPhotosPerSection)
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
                        : "Agregar más (${photos.length}/$_maxPhotosPerSection)",
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
