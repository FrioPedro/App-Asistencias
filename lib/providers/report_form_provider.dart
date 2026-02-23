import 'dart:io';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:app_asistencias/domain/note/sync_note.dart';
import 'package:app_asistencias/models/taskType_model.dart';
import 'package:app_asistencias/models/activity/list_form_model.dart';
import 'package:app_asistencias/domain/note/create_note.dart';

class ServiceExitAsNotes {
  static Future<bool> saveAll({
    required int sid,
    required TaskType taskType,
    required String incidencias,
    required String conclusiones,
    required String recomendaciones,
    required String acciones,
    required List<AssetEntity> photosAntes,
    required List<AssetEntity> photosDespues,
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
        final File? file = await photosAntes[i].file;
        if (file == null) continue;

        await CreateNote.createAndStore(
            document: doc,
            description: 'Foto Antes',
            imagePath: file.path,
            activity: activityKey,
            taskType: taskType,
            type: ListForm.foto_antes);
      }

      // 3) Fotos DESPUÉS
      for (int i = 0; i < photosDespues.length; i++) {
        final File? file = await photosDespues[i].file;
        if (file == null) continue;

        await CreateNote.createAndStore(
            document: doc,
            description: 'Foto Después',
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
    required List<AssetEntity> photosDespues,
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
        final File? file = await photosAntes[i].file;
        if (file == null) continue;

        await CreateNote.createAndStore(
            document: doc,
            description: 'Foto Antes',
            imagePath: file.path,
            activity: activityKey,
            taskType: taskType,
            type: ListForm.foto_antes);
      }

      // 3) Fotos DESPUÉS
      for (int i = 0; i < photosDespues.length; i++) {
        final File? file = await photosDespues[i].file;
        if (file == null) continue;

        await CreateNote.createAndStore(
            document: doc,
            description: 'Foto Después',
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
