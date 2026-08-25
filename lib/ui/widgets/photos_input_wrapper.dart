import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class PhotosInputWrapper extends StatefulWidget {
  final int maxPhotos;
  final Function(List<AssetEntity>) onSelectionChanged;

  const PhotosInputWrapper({
    super.key,
    this.maxPhotos = 3,
    required this.onSelectionChanged,
  });

  @override
  State<PhotosInputWrapper> createState() => _PhotosInputWrapperState();
}

class _PhotosInputWrapperState extends State<PhotosInputWrapper> {
  List<AssetEntity> _selectedAssets = [];

  Future<void> _pickAssets() async {
    final AssetPickerConfig pickerConfig = AssetPickerConfig(
      maxAssets: widget.maxPhotos,
      selectedAssets: _selectedAssets,
      requestType: RequestType.image,
      specialPickerType: SpecialPickerType.noPreview,
      specialItemPosition: SpecialItemPosition.prepend,
      specialItemBuilder: (context, path, length) {
        return SizedBox.expand(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceAlt,
              elevation: 0,
              padding: const EdgeInsets.all(AppSpacing.xs),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const RoundedRectangleBorder(),
            ),
            onPressed: () async {
              // El pop cierra el picker, no esta pantalla: se toma el Navigator
              // de su context antes de abrir la camara.
              final navigator = Navigator.of(context);

              final AssetEntity? result = await CameraPicker.pickFromCamera(
                context,
                pickerConfig: const CameraPickerConfig(
                  enableRecording: false,
                  shouldDeletePreviewFile: true,
                ),
              );

              if (result != null) navigator.pop([result]);
            },
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, color: Colors.white, size: 30),
                SizedBox(height: AppSpacing.xs),
                Flexible(
                  child: Text(
                    "Cámara",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
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

    if (result != null) {
      _updateSelection(result);
    }
  }

  void _updateSelection(List<AssetEntity> newAssets) {
    if (newAssets.length > widget.maxPhotos) {
      newAssets = newAssets.sublist(0, widget.maxPhotos);
    }
    setState(() => _selectedAssets = newAssets);
    widget.onSelectionChanged(newAssets);
  }

  void _removeAsset(AssetEntity asset) {
    setState(() => _selectedAssets.remove(asset));
    widget.onSelectionChanged(_selectedAssets);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedAssets.isNotEmpty)
          Container(
            height: 110,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedAssets.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final asset = _selectedAssets[index];
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
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
                        onTap: () => _removeAsset(asset),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
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
        if (_selectedAssets.length < widget.maxPhotos)
          ElevatedButton(
            onPressed: _pickAssets,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textSecondary,
              elevation: 0,
              minimumSize: const Size.fromHeight(AppSpacing.ctaHeight),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              side: const BorderSide(color: AppColors.border),
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
                      child: Icon(Icons.add_a_photo,
                          color: AppColors.textSecondary,
                          size: MediaQuery.textScalerOf(context).scale(20)),
                    ),
                  ),
                  TextSpan(
                    text: _selectedAssets.isEmpty
                        ? "Subir Fotos (Máx ${widget.maxPhotos})"
                        : "Agregar más (${_selectedAssets.length}/${widget.maxPhotos})",
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
