import 'package:isar/isar.dart';

part 'user_model.g.dart';

@collection
class UserModel {
  Id id = Isar.autoIncrement;
  int? serverId;
  String? nationalId;
  String? names;
  String? lastNames;
  String? zone;
  String token;

  UserModel({
    this.serverId,
    this.nationalId,
    this.names,
    this.lastNames,
    this.zone,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      serverId: json['id'],
      nationalId: json['nationalId'],
      names: json['names'],
      lastNames: json['lastNames'],
      zone: json['branchId'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': serverId,
    'nationalId': nationalId,
    'names': names,
    'lastNames': lastNames,
    'branch': zone,
    'token': token,
  };
}
