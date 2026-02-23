import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/models/note_model.dart';
import 'package:app_asistencias/models/taskType_model.dart';
import 'package:app_asistencias/models/activity/list_form_model.dart';

class CreateNote {
  static Future<NoteModel> createAndStore({
    required String document,
    String description = '',
    required TaskType taskType,
    String? imagePath,
    String? activity,
    ListForm type = ListForm.foto_antes,
  }) async {
    final activityKey = taskType.name;

    final ts = DateTime.now();

    final note = NoteModel(
      document: document,
      description: description,
      imagePath: imagePath,
      activity: activity,
      timestamp: ts,
      syncStatus: SyncStatus.pending,
      taskType: taskType,
      type: type,
    );

    print(
        '[NOTE] dedupKey=${note.dedupKey} doc=${note.document} desc=${note.description}');

    final isar = await Database.instance();
    await isar.writeTxn(() async {
      await isar.noteModels.put(note);
    });
    print('[NOTE] saved id=${note.id}');

    return note;
  }
}
