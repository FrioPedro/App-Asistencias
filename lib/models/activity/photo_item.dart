import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

/// Una foto del formulario de salida junto con su descripción.
///
/// El [TextEditingController] vive aquí (y por lo tanto en el state del sheet
/// que arma la lista), no en la pantalla que edita el texto. Así el operario
/// puede entrar y salir de la vista de descripción sin perder nada, y la
/// descripción siempre viaja pegada a su foto: al borrar la foto se borra su
/// texto, sin riesgo de desalinear índices.
class PhotoItem {
  final AssetEntity asset;
  final TextEditingController caption;

  /// `true` solo si la foto se tomó con la cámara de la app. Las elegidas de
  /// la galería son fotos que ya eran del operario, así que nunca se borran
  /// del dispositivo aunque el formulario las descarte.
  final bool fromCamera;

  PhotoItem(
    this.asset, {
    String initialCaption = '',
    this.fromCamera = false,
  }) : caption = TextEditingController(text: initialCaption);

  /// Mínimo de caracteres exigido a cada descripción de foto.
  static const int minCaptionChars = 10;

  bool get isDescribed => caption.text.trim().length >= minCaptionChars;

  void dispose() => caption.dispose();
}
