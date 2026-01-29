import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:app_asistencias/models/activity_model.dart';
import 'package:app_asistencias/models/assigment_model.dart';
import 'package:app_asistencias/models/user_model.dart';
import 'package:app_asistencias/models/note_model.dart';

class Database {
  static Isar? _instance;

  /// Obtiene o crea la instancia única de Isar.
  static Future<Isar> instance() async {
    if (_instance != null  && _instance!.isOpen) return _instance!;

    final dir = await getApplicationDocumentsDirectory();

    _instance = await Isar.open(
      [
        ActivityModelSchema,
        AssigmentModelSchema,
        UserModelSchema,
        NoteModelSchema,
      ],
      directory: dir.path,
      inspector: true, 
    );

    // Inicializar datos por defecto al abrir
    await _seedDefaultData(_instance!);

    return _instance!;
  }

  /// Cierra la instancia actual de Isar (si está abierta)
  static Future<bool> close() async {
    if (_instance == null) return true;
    await _instance!.close();
    _instance = null;
    return true;
  }

  /// Carga datos iniciales si la base está vacía.
  static Future<void> _seedDefaultData(Isar isar) async {

  
    // Aquí puedes agregar más "seed data" para otros modelos:
    // await _seedUsers(isar);
    // await _seedAppState(isar);
  }
}
