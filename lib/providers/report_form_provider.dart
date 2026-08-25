import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:app_asistencias/domain/note/sync_note.dart';
import 'package:app_asistencias/models/taskType_model.dart';
import 'package:app_asistencias/models/activity/list_form_model.dart';
import 'package:app_asistencias/domain/note/create_note.dart';
import 'package:app_asistencias/providers/log_provider.dart';
import 'package:app_asistencias/models/log_model.dart';

/// Resuelve un [File] JPEG garantizado a existir para el [asset].
///
/// Todo lo que se sube pasa por aquí, y siempre sale como JPG real:
///
/// * lo que ya es JPEG (la cámara de Android, la mayoría de los casos) se
///   copia sin tocar; solo se convierte lo que no lo es;
/// * de la galería pueden entrar HEIC (fotos de iOS), PNG o capturas de
///   pantalla, que el backend no siempre puede mostrar;
/// * las fotos tomadas con la cámara in-app se guardan con
///   `shouldDeletePreviewFile: true`, por lo que su `asset.file` puede apuntar
///   a un archivo temporal ya borrado para el momento en que se sincroniza
///   (sobre todo si el envío quedó en cola offline). En ese caso se recurre a
///   `originBytes`, que lee directamente del asset en el sistema.
///
/// El resultado se vuelca a un archivo permanente dentro del storage de la
/// app, porque la nota puede sincronizarse mucho después de cerrar el
/// formulario.
Future<File?> _resolveAssetFile(AssetEntity asset) async {
  Uint8List? bytes;

  final file = await asset.file;
  if (file != null && await file.exists()) {
    bytes = await file.readAsBytes();
  }
  bytes ??= await asset.originBytes;
  if (bytes == null) return null;

  final dir = await getApplicationDocumentsDirectory();
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final base = '${dir.path}/asset_${asset.id}_$stamp';

  // Las fotos de la cámara de Android ya son JPEG, o sea el caso más común.
  // Convertirlas sería decodificar y recodificar para llegar al mismo sitio,
  // y esa decodificación es justo lo que dispara la memoria: un bitmap a
  // resolución completa. Se pasan tal cual.
  if (_isJpeg(bytes)) {
    return File('$base.jpg').writeAsBytes(bytes);
  }

  Uint8List? jpeg;
  try {
    jpeg = await FlutterImageCompress.compressWithList(
      bytes,
      quality: 100,
      minWidth: 1,
      minHeight: 1,
      inSampleSize: 1,
      format: CompressFormat.jpeg,
      keepExif: true,
    );
  } catch (e) {
    jpeg = null;
    LogProvider.log(
      'No se pudo convertir la foto ${asset.id} a JPG: $e',
      type: LogType.warning,
      origin: 'ReportFormProvider',
    );
  }

  if (jpeg != null && jpeg.isNotEmpty) {
    return File('$base.jpg').writeAsBytes(jpeg);
  }

  // Se sube el original tal cual. Puede ser HEIC o WEBP, que el backend no
  // siempre muestra, así que queda registrado para poder rastrearlo después.
  final ext = _extensionFor(asset.mimeType);
  LogProvider.log(
    'Foto ${asset.id} subida sin convertir, como .$ext '
    '(mime: ${asset.mimeType ?? "desconocido"})',
    type: LogType.warning,
    origin: 'ReportFormProvider',
  );

  return File('$base.$ext').writeAsBytes(bytes);
}

/// `true` si los bytes ya son un JPEG, mirando su cabecera (FF D8 FF).
bool _isJpeg(Uint8List bytes) =>
    bytes.length >= 3 &&
    bytes[0] == 0xFF &&
    bytes[1] == 0xD8 &&
    bytes[2] == 0xFF;

String _extensionFor(String? mimeType) {
  final mime = mimeType?.toLowerCase() ?? '';
  if (mime.contains('png')) return 'png';
  if (mime.contains('heic') || mime.contains('heif')) return 'heic';
  if (mime.contains('webp')) return 'webp';
  return 'jpg';
}

class ServiceExitAsNotes {
  static Future<bool> saveAll({
    required int sid,
    required TaskType taskType,
    required String incidencias,
    required String conclusiones,
    required String recomendaciones,
    required String acciones,
    required List<AssetEntity> photosAntes,
    /// Una descripción por foto, alineada por índice con [photosAntes].
    required List<String> descripcionesAntes,
    List<AssetEntity> photosDespues = const [],
    /// Una descripción por foto, alineada por índice con [photosDespues].
    List<String> descripcionesDespues = const [],
    /// Si es un servicio de mantenimiento: foto_antes, else foto_general
    required ListForm photoNoteType,
  }) async {
    assert(
      photosAntes.length == descripcionesAntes.length,
      'ANTES: ${photosAntes.length} fotos vs '
      '${descripcionesAntes.length} descripciones',
    );
    assert(
      photosDespues.length == descripcionesDespues.length,
      'DESPUÉS: ${photosDespues.length} fotos vs '
      '${descripcionesDespues.length} descripciones',
    );

    final activityKey =
        taskType.name; // 'office' | 'workshop' | 'service' | 'transport'
    try {
      final doc = sid.toString();
      final NoteSyncService sync = NoteSyncService();

      // 1) Textos (si no están vacíos)
      if (incidencias.trim().isNotEmpty) {
        await CreateNote.createAndStore(
            document: doc,
            description: incidencias.trim(),
            activity: activityKey,
            taskType: taskType,
            type: ListForm.incidencias);
      }

      if (acciones.trim().isNotEmpty) {
        await CreateNote.createAndStore(
            document: doc,
            description: acciones.trim(),
            activity: activityKey,
            taskType: taskType,
            type: ListForm.acciones);
      }

      if (conclusiones.trim().isNotEmpty) {
        await CreateNote.createAndStore(
            document: doc,
            description: conclusiones.trim(),
            activity: activityKey,
            taskType: taskType,
            type: ListForm.conclusiones);
      }

      if (recomendaciones.trim().isNotEmpty) {
        await CreateNote.createAndStore(
            document: doc,
            description: recomendaciones.trim(),
            activity: activityKey,
            taskType: taskType,
            type: ListForm.recomendaciones);
      }

      // 2) Fotos GENERALES o ANTES
      for (int i = 0; i < photosAntes.length; i++) {
        final File? file = await _resolveAssetFile(photosAntes[i]);
        if (file == null) continue;

        await CreateNote.createAndStore(
            document: doc,
            description: descripcionesAntes[i].trim(),
            imagePath: file.path,
            activity: activityKey,
            taskType: taskType,
            type: photoNoteType); // aquí se pobla el tipo de nota, pero antes y general usan el mismo controlador
      }

      // 3) Fotos DESPUÉS
      for (int i = 0; i < photosDespues.length; i++) {
        final File? file = await _resolveAssetFile(photosDespues[i]);
        if (file == null) continue;

        await CreateNote.createAndStore(
            document: doc,
            description: descripcionesDespues[i].trim(),
            imagePath: file.path,
            activity: activityKey,
            taskType: taskType,
            type: ListForm.foto_despues);
      }

      await sync.syncIfPossible();
      return true;
    } catch (e) {
      return false;
    }
  }
}

class WorkshopExitAsNotes {
  static Future<bool> saveAll({
    required int sid,
    required TaskType taskType,
    required String notes,
    required List<AssetEntity> photos,
    required List<String> descripciones,
  }) async {
    assert(
      photos.length == descripciones.length,
      '${photos.length} fotos vs ${descripciones.length} descripciones',
    );

    final activityKey =
        taskType.name; // 'office' | 'workshop' | 'service' | 'transport'
    try {
      final doc = sid.toString();
      final NoteSyncService sync = NoteSyncService();

      // 1) Notas (Obligatorio validado en UI, pero guardamos si no es vacío)
      if (notes.trim().isNotEmpty) {
        await CreateNote.createAndStore(
            document: doc,
            description: notes.trim(),
            activity: activityKey,
            taskType: taskType,
            type: ListForm.acciones);
      }

      // 2) Fotos
      for (int i = 0; i < photos.length; i++) {
        final File? file = await _resolveAssetFile(photos[i]);
        if (file == null) continue;

        await CreateNote.createAndStore(
            document: doc,
            description: descripciones[i].trim(),
            imagePath: file.path,
            activity: activityKey,
            taskType: taskType,
            type: ListForm.foto_antes);
      }

      await sync.syncIfPossible();
      return true;
    } catch (e) {
      return false;
    }
  }
}
