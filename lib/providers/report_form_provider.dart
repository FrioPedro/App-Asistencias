import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:app_asistencias/domain/note/sync_note.dart';
import 'package:app_asistencias/models/taskType_model.dart';
import 'package:app_asistencias/models/activity/list_form_model.dart';
import 'package:app_asistencias/domain/note/create_note.dart';

/// Resuelve un [File] garantizado a existir para el [asset].
///
/// Las fotos tomadas con la cámara in-app se guardan con
/// `shouldDeletePreviewFile: true`, por lo que su `asset.file` puede apuntar
/// a un archivo temporal ya borrado para el momento en que se sincroniza
/// (sobre todo si el envío quedó en cola offline). En ese caso se recurre a
/// `originBytes`, que lee directamente del asset en el sistema, y se
/// vuelca a un archivo permanente dentro del storage de la app.
Future<File?> _resolveAssetFile(AssetEntity asset) async {
  final file = await asset.file;
  if (file != null && await file.exists()) {
    return file;
  }

  final bytes = await asset.originBytes;
  if (bytes == null) return null;

  final dir = await getApplicationDocumentsDirectory();
  final ext = asset.mimeType?.contains('png') == true ? 'png' : 'jpg';
  final persisted =
      File('${dir.path}/asset_${asset.id}_${DateTime.now().millisecondsSinceEpoch}.$ext');
  await persisted.writeAsBytes(bytes);
  return persisted;
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
    required String descripcionAntes,
    required List<AssetEntity> photosDespues,
    required String descripcionDespues,
  }) async {
    final activityKey =
        taskType.name; // 'office' | 'workshop' | 'service' | 'transport'
    try {
      final doc = sid.toString();
      final NoteSyncService _sync = NoteSyncService();

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

      // 2) Fotos ANTES
      for (int i = 0; i < photosAntes.length; i++) {
        final File? file = await _resolveAssetFile(photosAntes[i]);
        if (file == null) continue;

        await CreateNote.createAndStore(
            document: doc,
            description: descripcionAntes,
            imagePath: file.path,
            activity: activityKey,
            taskType: taskType,
            type: ListForm.foto_antes);
      }

      // 3) Fotos DESPUÉS
      for (int i = 0; i < photosDespues.length; i++) {
        final File? file = await _resolveAssetFile(photosDespues[i]);
        if (file == null) continue;

        await CreateNote.createAndStore(
            document: doc,
            description: descripcionDespues,
            imagePath: file.path,
            activity: activityKey,
            taskType: taskType,
            type: ListForm.foto_despues);
      }

      await _sync.syncIfPossible();
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
    required List<AssetEntity> photosAntes,
    required String descripcionAntes,
    required List<AssetEntity> photosDespues,
    required String descripcionDespues,
  }) async {
    final activityKey =
        taskType.name; // 'office' | 'workshop' | 'service' | 'transport'
    try {
      final doc = sid.toString();
      final NoteSyncService _sync = NoteSyncService();

      // 1) Notas (Obligatorio validado en UI, pero guardamos si no es vacío)
      if (notes.trim().isNotEmpty) {
        await CreateNote.createAndStore(
            document: doc,
            description: notes.trim(),
            activity: activityKey,
            taskType: taskType,
            type: ListForm.acciones);
      }

      // 2) Fotos ANTES
      for (int i = 0; i < photosAntes.length; i++) {
        final File? file = await _resolveAssetFile(photosAntes[i]);
        if (file == null) continue;

        await CreateNote.createAndStore(
            document: doc,
            description: descripcionAntes,
            imagePath: file.path,
            activity: activityKey,
            taskType: taskType,
            type: ListForm.foto_antes);
      }

      // 3) Fotos DESPUÉS
      for (int i = 0; i < photosDespues.length; i++) {
        final File? file = await _resolveAssetFile(photosDespues[i]);
        if (file == null) continue;

        await CreateNote.createAndStore(
            document: doc,
            description: descripcionDespues,
            imagePath: file.path,
            activity: activityKey,
            taskType: taskType,
            type: ListForm.foto_despues);
      }

      await _sync.syncIfPossible();
      return true;
    } catch (e) {
      return false;
    }
  }
}
