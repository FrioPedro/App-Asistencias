import 'package:app_asistencias/domain/note/sync_note.dart';
import 'package:app_asistencias/models/note_model.dart';
import 'package:app_asistencias/domain/note/create_note.dart'; // tu CreateNote
import 'package:app_asistencias/models/taskType_model.dart';
import 'package:app_asistencias/models/activity/list_form_model.dart';


class NotesProvider {
  final NoteSyncService _sync = NoteSyncService();

  /// Crea nota local (pending) + intenta sync
  Future<NoteModel> createNote({
    required String document,
    required String description,
    String? imagePath,
    String? activity,
    required TaskType taskType,
    required ListForm type,
  }) async {

    // 1) crear nota local (pending)

    final note = await CreateNote.createAndStore(
      document: document,
      description: description,
      imagePath: imagePath,
      activity: activity,
      taskType: taskType,
      type: type,
    );


    // 3) intentar sincronizar
    await _sync.syncIfPossible();

    return note;
  }

/*
  /// Trae notas locales (para mostrar en UI)
  Future<List<NoteModel>> fetchLocalNotes({
    String? document, // si quieres filtrar por documento
    int limit = 200,
  }) async {
    final isar = await Database.instance();

    if (document == null) {
      return isar.noteModels
          .where()
          .sortByTimestampDesc()
          .limit(limit)
          .findAll();
    }

    return isar.noteModels
        .filter()
        .documentEqualTo(document)
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
  }

  /// Forzar sync manual (botón "Reintentar")
  Future<void> syncNow() => _sync.syncIfPossible();
*/

}
