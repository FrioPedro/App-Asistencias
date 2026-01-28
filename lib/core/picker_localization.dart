import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

/// Textos en español para el selector de fotos (wechat_assets_picker)
class SpanishAssetPickerTextDelegate extends AssetPickerTextDelegate {
  const SpanishAssetPickerTextDelegate();

  @override
  String get languageCode => 'es';

  @override
  String get confirm => 'Confirmar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get edit => 'Editar';

  @override
  String get gifIndicator => 'GIF';

  @override
  String get loadFailed => 'Error al cargar';

  @override
  String get original => 'Original';

  @override
  String get preview => 'Vista previa';

  @override
  String get select => 'Seleccionar';

  @override
  String get emptyList => 'Lista vacía';

  @override
  String get unSupportedAssetType => 'Tipo no soportado';

  @override
  String get unableToAccessAll => 'No se puede acceder a todos los archivos';

  @override
  String get viewingLimitedAssetsTip =>
      'Solo se muestran los archivos accesibles por la app.';

  @override
  String get changeAccessibleLimitedAssets => 'Actualizar archivos accesibles';

  @override
  String get accessAllTip => 'La app solo puede acceder a algunos archivos. '
      'Ve a configuración para permitir acceso a todos los archivos.';

  @override
  String get goToSystemSettings => 'Ir a configuración';

  @override
  String get accessLimitedAssets => 'Continuar con acceso limitado';

  @override
  String get accessiblePathName => 'Archivos accesibles';

  @override
  String durationIndicatorBuilder(Duration duration) {
    const String separator = ':';
    final String minute = duration.inMinutes.toString().padLeft(2, '0');
    final String second =
        ((duration - Duration(minutes: duration.inMinutes)).inSeconds)
            .toString()
            .padLeft(2, '0');
    return '$minute$separator$second';
  }

  // Métodos de ayuda para 9.8.0
  @override
  String get sActionPlayHint => 'Reproducir';

  @override
  String get sActionPreviewHint => 'Vista previa';

  @override
  String get sActionSwitchPathLabel => 'Cambiar carpeta';

  @override
  String get sActionUseCameraHint => 'Usar cámara';

  @override
  String get sTypeAudioLabel => 'Audio';

  @override
  String get sTypeImageLabel => 'Imagen';

  @override
  String get sTypeVideoLabel => 'Video';

  @override
  String get sTypeOtherLabel => 'Otro';
}

/// Textos en español para el picker de cámara (wechat_camera_picker)
class SpanishCameraPickerTextDelegate extends CameraPickerTextDelegate {
  const SpanishCameraPickerTextDelegate();

  @override
  String get languageCode => 'es';

  @override
  String get confirm => 'Confirmar';

  @override
  String get shootingTips => 'Toca para tomar foto';

  @override
  String get shootingWithRecordingTips => 'Toca para foto, mantén para video';

  @override
  String get shootingOnlyRecordingTips => 'Mantén presionado para grabar';

  @override
  String get shootingTapRecordingTips => 'Toca para grabar';

  @override
  String get loadFailed => 'Error al cargar';

  @override
  String get saving => 'Guardando...';

  @override
  String get sActionManuallyFocusHint => 'Enfocar manualmente';

  @override
  String get sActionPreviewHint => 'Vista previa';

  @override
  String get sActionRecordHint => 'Grabar';

  @override
  String get sActionShootHint => 'Tomar foto';

  @override
  String get sActionShootingButtonTooltip => 'Botón de captura';

  @override
  String get sActionStopRecordingHint => 'Detener grabación';
}
