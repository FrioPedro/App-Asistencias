import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:app_asistencias/models/activity/activity_model.dart';
import 'package:app_asistencias/models/assigment_model.dart';
import 'package:app_asistencias/models/user/user_model.dart';
import 'package:app_asistencias/models/note_model.dart';
import 'package:app_asistencias/models/log_model.dart';

class Database {
  static Isar? _instance;
  static Future<Isar>? _opening; // ✅ lock contra doble open

  static Future<Isar> instance() {
    // ✅ si ya está abierta, devolver
    if (_instance != null && _instance!.isOpen) return Future.value(_instance!);

    // ✅ si ya se está abriendo en paralelo, esperar esa misma
    _opening ??= _openInternal();
    return _opening!;
  }

  static Future<Isar> _openInternal() async {
    // 1) si Isar ya existe (hot restart / alguien lo abrió antes), reusar
    final existing = Isar.getInstance();
    if (existing != null && existing.isOpen) {
      _instance = existing;
      await _seedDefaultData(_instance!);
      return _instance!;
    }

    // 2) abrir normalmente
    final dir = await getApplicationDocumentsDirectory();

    _instance = await Isar.open(
      [
        ActivityModelSchema,
        AssigmentModelSchema,
        UserModelSchema,
        NoteModelSchema,
        LogModelSchema,
      ],
      directory: dir.path,
      inspector: true,
    );

    await _seedDefaultData(_instance!);

    return _instance!;
  }

  static Future<bool> close() async {
    if (_instance == null) return true;
    await _instance!.close();
    _instance = null;
    _opening = null;
    return true;
  }

  static Future<void> _seedDefaultData(Isar isar) async {
    // IMPORTANTE: dejar esto idempotente si luego insertas cosas
  }
}
