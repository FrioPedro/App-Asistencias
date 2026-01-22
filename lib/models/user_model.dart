import 'package:isar/isar.dart';

part 'user_model.g.dart';

@collection
class UserModel {
  Id id = Isar.autoIncrement;
  String? nationalId;
  String? names;
  String? lastNames;
  String? zone;

  UserModel({
    this.nationalId,
    this.names,
    this.lastNames,
    this.zone,
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
      zone: json['zone'],
    );
  }

  Map<String, dynamic> toJson() => {
        'documento': nationalId,
        'nombres': names,
        'apellidos': lastNames,
        'zone': zone,
      };
}
