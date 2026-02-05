import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/models/user/user_model.dart';

class ClearUser {
  static Future<void> clearLocalData() async {
    final isar = await Database.instance();
    await isar.writeTxn(() async {
      await isar.userModels.clear();
    });
  }
}
