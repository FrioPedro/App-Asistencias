import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/models/note_model.dart';

class CreateNote {

  static Future<NoteModel> createAndStore({
    required String document,
    required String description,
    String? imagePath,
    String? activity,
  }) async {
    final ts = DateTime.now();

    final note = NoteModel(
      document: document,
      description: description,
      imagePath: imagePath,
      activity: activity,
      timestamp: ts,
      syncStatus: SyncStatus.pending,
    );

    print('[NOTE] dedupKey=${note.dedupKey} doc=${note.document} desc=${note.description}');

    final isar = await Database.instance();
    await isar.writeTxn(() async {
      await isar.noteModels.put(note);
    });
    print('[NOTE] saved id=${note.id}');

    return note;
  }
}
