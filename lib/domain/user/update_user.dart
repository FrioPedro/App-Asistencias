// lib/domain/user/update_user.dart
import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/models/user_model.dart';
import 'package:app_asistencias/models/user_zone.dart';
import 'package:isar/isar.dart';

class UpdateUser {
  /// Actualiza la zona del usuario (SOLO Sur | Centro | Norte)
  static Future<UserModel?> updateZone(UserZone zone) async {
    final isar = await Database.instance();

    final user = await isar.userModels.where().findFirst();
    if (user == null) {
      print("[USER] updateZone: no local user found");
      return null;
    }

    await isar.writeTxn(() async {
      user.zone = zone.label; // "Sur" | "Centro" | "Norte"
      await isar.userModels.put(user);
    });

    print("[USER] zone updated to: ${zone.label}");
    return user;
  }

  /// Variante por String (si viene de UI)
  static Future<UserModel?> updateZoneFromString(String value) async {
    final zone = UserZoneX.fromString(value);
    if (zone == null) {
      print("[USER] updateZoneFromString: invalid zone='$value'");
      return null;
    }
    return updateZone(zone);
  }

  /// Lectura rápida de zona actual (String)
  static Future<String?> getZoneLabel() async {
    final isar = await Database.instance();
    final user = await isar.userModels.where().findFirst();
    return user?.zone;
  }
}
