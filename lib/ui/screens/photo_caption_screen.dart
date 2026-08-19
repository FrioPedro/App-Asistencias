import 'package:flutter/material.dart';
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
  static const Color _bgColor = Color(0xFF121212);
  static const Color _cardColor = Color(0xFF2C2C2C);
  static const Color _primaryBlue = Color(0xFF2E60C4);
  static const Color _exitRed = Color(0xFFEF5350);
  static const Color _pendingAmber = Color(0xFFFFB300);
  static const Color _okGreen = Color(0xFF4CAF50);

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
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '¿Borrar esta foto?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Se borrará la foto y su descripción. No se puede recuperar.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _exitRed,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
      backgroundColor: _bgColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text(
                  'Guardar y volver',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            Text(
              '$_describedCount de ${widget.photos.length} ✓',
              style: TextStyle(
                color: _describedCount == widget.photos.length
                    ? _okGreen
                    : _pendingAmber,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Foto ${_index + 1} de ${widget.photos.length}  ·  ${widget.sectionLabel}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AssetEntityImage(
                    _current.asset,
                    key: ValueKey(_current.asset.id),
                    height: photoHeight,
                    fit: BoxFit.contain,
                    isOriginal: false,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                      const SizedBox(height: 8),
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
                          fillColor: _cardColor,
                          hintText:
                              'Ej: Serpentín con hielo antes de la limpieza.',
                          hintStyle:
                              TextStyle(color: Colors.grey[600], fontSize: 15),
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusRow(),
                      const SizedBox(height: 20),
                      _buildThumbnailStrip(),
                    ],
                  ),
                ),
              ),
              _buildActions(),
              const SizedBox(height: 16),
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
                color: ok ? _okGreen : _pendingAmber,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                ok ? 'Guardado' : 'Escribe un poco más',
                style: TextStyle(
                  color: ok ? _okGreen : _pendingAmber,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        else
          Text(
            'Escribe al menos ${PhotoItem.minCaptionChars} letras',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        Text(
          '$length/${PhotoItem.minCaptionChars}',
          style: TextStyle(
            color: ok ? _okGreen : Colors.grey[500],
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
        padding: EdgeInsets.only(bottom: end < total ? 6 : 0),
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
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => _goTo(i),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 44,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCurrent
                      ? Colors.white
                      : (item.isDescribed ? _okGreen : _pendingAmber),
                  width: isCurrent ? 2.5 : 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
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
                  color: item.isDescribed ? _okGreen : _pendingAmber,
                  shape: BoxShape.circle,
                  border: Border.all(color: _bgColor, width: 1.5),
                ),
                child: Icon(
                  item.isDescribed ? Icons.check : Icons.priority_high,
                  color: Colors.white,
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
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _confirmRemove,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text(
              'Borrar foto',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _exitRed,
              side: const BorderSide(color: _exitRed),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
                  const SizedBox(width: 8),
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
