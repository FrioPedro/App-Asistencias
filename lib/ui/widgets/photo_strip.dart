import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../models/activity/photo_item.dart';

/// Tira horizontal de miniaturas de un grupo de fotos.
///
/// Con el tope de 20 fotos por sección la lista casi nunca cabe en pantalla, y
/// una miniatura cortada al borde se lee como "solo hay 3 fotos". Para que
/// quede claro que se puede deslizar, un degradado en el borde derecho (y en
/// el izquierdo al avanzar) deja la última miniatura visible desvaneciéndose
/// en lugar de cortada en seco.
///
/// Tocar una miniatura llama a [onTapPhoto] con su índice.
class PhotoStrip extends StatefulWidget {
  final List<PhotoItem> photos;
  final void Function(int index)? onTapPhoto;

  const PhotoStrip({
    super.key,
    required this.photos,
    this.onTapPhoto,
  });

  @override
  State<PhotoStrip> createState() => _PhotoStripState();
}

class _PhotoStripState extends State<PhotoStrip> {

  static const double _thumbSize = 100;
  static const double _gap = 12;
  static const double _fadeWidth = 28;

  final _controller = ScrollController();

  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    // El primer frame ya sabe el ancho disponible; recién ahí se puede decidir
    // si la lista desborda.
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void didUpdateWidget(PhotoStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Al agregar o borrar fotos cambia si la lista desborda.
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted || !_controller.hasClients) return;

    final position = _controller.position;
    final left = position.pixels > 4;
    final right = position.pixels < position.maxScrollExtent - 4;

    if (left != _canScrollLeft || right != _canScrollRight) {
      setState(() {
        _canScrollLeft = left;
        _canScrollRight = right;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _thumbSize + 20,
      child: Stack(
        children: [
          ListView.separated(
            controller: _controller,
            padding: const EdgeInsets.symmetric(vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: widget.photos.length,
            separatorBuilder: (_, __) => const SizedBox(width: _gap),
            itemBuilder: (context, index) => _buildThumbnail(index),
          ),
          if (_canScrollLeft) _buildFade(alignLeft: true),
          if (_canScrollRight) _buildFade(alignLeft: false),
        ],
      ),
    );
  }

  /// Degradado que desvanece la miniatura del borde en lugar de cortarla.
  Widget _buildFade({required bool alignLeft}) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: alignLeft ? 0 : null,
      right: alignLeft ? null : 0,
      child: IgnorePointer(
        child: Container(
          width: _fadeWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
              end: alignLeft ? Alignment.centerRight : Alignment.centerLeft,
              colors: const [AppColors.bg, Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(int index) {
    final item = widget.photos[index];
    final described = item.isDescribed;

    // Tocar la miniatura abre esa foto directamente, para describir o corregir
    // en cualquier orden.
    return GestureDetector(
      onTap: widget.onTapPhoto == null ? null : () => widget.onTapPhoto!(index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: described ? AppColors.success : AppColors.warning,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AssetEntityImage(
                item.asset,
                width: _thumbSize,
                height: _thumbSize,
                fit: BoxFit.cover,
                isOriginal: false,
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: described ? AppColors.success : AppColors.warning,
                shape: BoxShape.circle,
              ),
              child: Icon(
                described ? Icons.check : Icons.priority_high,
                color: AppColors.onAccent,
                size: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
