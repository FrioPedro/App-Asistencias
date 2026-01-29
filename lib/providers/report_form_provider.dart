import 'dart:io';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:app_asistencias/domain/note/sync_note.dart';
import 'package:app_asistencias/models/note_model.dart';
import 'package:app_asistencias/domain/note/create_note.dart';

class ServiceExitAsNotes {
  static Future<bool> saveAll({
    required int sid,
    required String incidencias,
    required String conclusiones,
    required String recomendaciones,
    required String acciones,
    required List<AssetEntity> photosAntes,
    required List<AssetEntity> photosDespues,
  }) async {
    try {
      final doc = sid.toString();
      final NoteSyncService _sync = NoteSyncService();

      // 1) Textos (si no están vacíos)
      if (incidencias.trim().isNotEmpty) {
        await CreateNote.createAndStore(
          document: doc,
          description: '[Incidencia Servicio]: ${incidencias.trim()}',
          //activity: 'SERVICE_EXIT',
        );
      }
      
      if (conclusiones.trim().isNotEmpty) {
        await CreateNote.createAndStore(
          document: doc,
          description: '[Conclusiones Servicio]: ${conclusiones.trim()}',
          //activity: 'SERVICE_EXIT',
        );
      }

      if (recomendaciones.trim().isNotEmpty) {
        await CreateNote.createAndStore(
          document: doc,
          description: '[Recomendaciones Servicio]: ${recomendaciones.trim()}',
          //activity: 'SERVICE_EXIT',
        );
      }
     
      // 2) Fotos ANTES
      for (int i = 0; i < photosAntes.length; i++) {
        final File? file = await photosAntes[i].file;
        if (file == null) continue;

        await CreateNote.createAndStore(
          document: doc,
          description: '[Foto Antes #${i + 1}]',
          imagePath: file.path,
          //activity: 'SERVICE_EXIT_PHOTO_BEFORE',
        );
      }

      // 3) Fotos DESPUÉS
      for (int i = 0; i < photosDespues.length; i++) {
        final File? file = await photosDespues[i].file;
        if (file == null) continue;

        await CreateNote.createAndStore(
          document: doc,
          description: '[Foto Después #${i + 1}]',
          imagePath: file.path,
          activity: 'SERVICE_EXIT_PHOTO_AFTER',
        );
      }

      await _sync.syncIfPossible();
      return true;
    } catch (e) {
      return false;
    }
  }
}
