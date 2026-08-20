import 'package:flutter/material.dart';
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
        return GestureDetector(
          onTap: () async {
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
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedAssets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final asset = _selectedAssets[index];
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
                        onTap: () => _removeAsset(asset),
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
        if (_selectedAssets.length < widget.maxPhotos)
          GestureDetector(
            onTap: _pickAssets,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(
                    _selectedAssets.isEmpty
                        ? "Subir Fotos (Máx ${widget.maxPhotos})"
                        : "Agregar más (${_selectedAssets.length}/${widget.maxPhotos})",
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
}
