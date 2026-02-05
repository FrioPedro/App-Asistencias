import 'package:isar/isar.dart';
import 'user_zone.dart';

part 'user_model.g.dart';

@collection
class UserModel {
  Id id = Isar.autoIncrement;
  String? nationalId;
  String? names;
  String? lastNames;

  @enumerated
  UserZone zone = UserZone.centro;
  
  bool active = true;


  UserModel({
    this.nationalId,
    this.names,
    this.lastNames,
    this.zone = UserZone.centro,
    this.active = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final collaborator = (json['Collaborator'] ?? '') as String;
    final parts = collaborator.trim().split(RegExp(r'\s+'));

    final name = parts.isNotEmpty ? parts.first : '';
    final lastNames = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return UserModel(
      nationalId: json['documento'] ?? json['Document'],
      names: json['nombres'] ?? name,
      lastNames: json['apellidos'] ?? lastNames,
      zone: UserZoneX.fromString((json['zone'] ?? '') as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'documento': nationalId,
        'nombres': names,
        'apellidos': lastNames,
        'zone': zone,
      };
}
