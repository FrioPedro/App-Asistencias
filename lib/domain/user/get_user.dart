import 'package:isar/isar.dart';
import 'package:app_asistencias/core/enpoinService.dart';
import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/models/user_model.dart';

class GetUser {
  /// Trae del API y guarda LOCALMENTE (único usuario)
  static Future<UserModel?> fetchAndStoreUser() async {
    final api = EndpointService.instance;

    final response = await api.get("/api/information");
    print("[GET USER] body: ${response.data}");

    if (response.statusCode != 200) return null;

    final user = UserModel.fromJson(response.data);
    final isar = await Database.instance();

    await isar.writeTxn(() async {
      // ❌ borrar cualquier usuario previo
      await isar.userModels.clear();

      // ✅ guardar el nuevo
      await isar.userModels.put(user);
    });

    return user;
  }

  /// Obtener usuario local (único)
  static Future<UserModel?> getUserLocal() async {
    final isar = await Database.instance();

    return await isar.userModels.where().findFirst();
  }
}
