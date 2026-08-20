import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../models/activity/photo_item.dart';

/// Pantalla para describir las fotos de un formulario de salida, una por
/// pantalla.
///
/// Recibe la lista **por referencia** desde el sheet padre y escribe
/// directamente en los controllers de cada [PhotoItem], así que volver atrás
/// nunca pierde lo escrito. El operario puede describir en cualquier orden:
/// las miniaturas de la parte baja saltan a la foto que toque.
///
/// [onRemove] permite borrar la foto desde aquí (con confirmación); el sheet
/// padre es el que hace el `dispose` del controller.
class PhotoCaptionScreen extends StatefulWidget {
  final List<PhotoItem> photos;
  final String sectionLabel;
  final int initialIndex;
  final void Function(PhotoItem item) onRemove;

  const PhotoCaptionScreen({
    super.key,
    required this.photos,
    required this.sectionLabel,
    required this.onRemove,
    this.initialIndex = 0,
  });

  @override
  State<PhotoCaptionScreen> createState() => _PhotoCaptionScreenState();
}

class _PhotoCaptionScreenState extends State<PhotoCaptionScreen> {
  static const int _thumbsPerRow = 8;

  final _focusNode = FocusNode();
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.photos.length - 1);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  PhotoItem get _current => widget.photos[_index];

  int get _describedCount => widget.photos.where((p) => p.isDescribed).length;

  bool get _isLast => _index >= widget.photos.length - 1;

  void _goTo(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    _focusNode.requestFocus();
  }

  void _onNext() {
    if (_isLast) {
      Navigator.pop(context);
    } else {
      _goTo(_index + 1);
    }
  }

  Future<void> _confirmRemove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text(
          '¿Borrar esta foto?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Se borrará la foto y su descripción. No se puede recuperar.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Sí, borrar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    widget.onRemove(_current);

    if (!mounted) return;
    if (widget.photos.isEmpty) {
      Navigator.pop(context);
      return;
    }
    setState(() => _index = _index.clamp(0, widget.photos.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    // Con el teclado abierto la foto se encoge para que el campo nunca quede
    // tapado.
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final photoHeight =
        keyboardOpen ? 120.0 : MediaQuery.of(context).size.height * 0.32;

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Guardar y volver',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Guardar y volver'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(
              child: Text(
                '$_describedCount de ${widget.photos.length} ✓',
                style: TextStyle(
                  color: _describedCount == widget.photos.length
                      ? AppColors.success
                      : AppColors.warning,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Foto ${_index + 1} de ${widget.photos.length}  ·  ${widget.sectionLabel}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: AssetEntityImage(
                    _current.asset,
                    key: ValueKey(_current.asset.id),
                    height: photoHeight,
                    fit: BoxFit.contain,
                    isOriginal: false,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¿QUÉ SE VE EN ESTA FOTO?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        // La key fuerza un campo nuevo al cambiar de foto, para
                        // que el cursor no herede la posición de la anterior.
                        key: ValueKey('caption_${_current.asset.id}'),
                        controller: _current.caption,
                        focusNode: _focusNode,
                        maxLines: 3,
                        minLines: 2,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() {}),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surface,
                          hintText:
                              'Ej: Serpentín con hielo antes de la limpieza.',
                          hintStyle: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 15),
                          contentPadding: const EdgeInsets.all(AppSpacing.lg),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildStatusRow(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildThumbnailStrip(),
                    ],
                  ),
                ),
              ),
              _buildActions(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  /// Confirmación en vivo de que el texto ya quedó guardado, más el mínimo
  /// exigido.
  Widget _buildStatusRow() {
    final length = _current.caption.text.trim().length;
    final ok = _current.isDescribed;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (length > 0)
          Row(
            children: [
              Icon(
                ok ? Icons.check_circle : Icons.edit_outlined,
                color: ok ? AppColors.success : AppColors.warning,
                size: 15,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                ok ? 'Guardado' : 'Escribe un poco más',
                style: TextStyle(
                  color: ok ? AppColors.success : AppColors.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        else
          const Text(
            'Escribe al menos ${PhotoItem.minCaptionChars} letras',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        Text(
          '$length/${PhotoItem.minCaptionChars}',
          style: TextStyle(
            color: ok ? AppColors.success : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailStrip() {
    final total = widget.photos.length;
    final rows = <Widget>[];

    for (int start = 0; start < total; start += _thumbsPerRow) {
      final end =
          (start + _thumbsPerRow) > total ? total : start + _thumbsPerRow;
      final count = end - start;

      rows.add(Padding(
        padding: EdgeInsets.only(bottom: end < total ? AppSpacing.sm : 0),
        child: Row(
          children: [
            for (int i = start; i < end; i++)
              Expanded(child: _buildThumbnail(i)),
            // Rellena la fila incompleta para que las miniaturas conserven el
            // mismo tamaño que en una fila llena.
            if (count < _thumbsPerRow)
              Expanded(
                flex: _thumbsPerRow - count,
                child: const SizedBox.shrink(),
              ),
          ],
        ),
      ));
    }

    return Column(children: rows);
  }

  Widget _buildThumbnail(int i) {
    final item = widget.photos[i];
    final isCurrent = i == _index;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: () => _goTo(i),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 44,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: isCurrent
                      ? Colors.white
                      : (item.isDescribed
                          ? AppColors.success
                          : AppColors.warning),
                  width: isCurrent ? 2.5 : 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox.expand(
                  child: AssetEntityImage(
                    item.asset,
                    fit: BoxFit.cover,
                    isOriginal: false,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color:
                      item.isDescribed ? AppColors.success : AppColors.warning,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bg, width: 1.5),
                ),
                child: Icon(
                  item.isDescribed ? Icons.check : Icons.priority_high,
                  color: AppColors.onAccent,
                  size: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        SizedBox(
          height: AppSpacing.ctaHeight,
          child: OutlinedButton.icon(
            onPressed: _confirmRemove,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text(
              'Borrar foto',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: SizedBox(
            height: AppSpacing.ctaHeight,
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLast ? 'LISTO' : 'SIGUIENTE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    _isLast ? Icons.check : Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
