import 'package:isar/isar.dart';

part 'log_model.g.dart';

enum LogType {
  info, //INF
  warning, //ADV
  error, //ERR
}

@collection
class LogModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  int? serverId;

  final String message;

  @enumerated
  final LogType type;
  final DateTime timestamp;
  final String? origin;
  final String? stackTrace;
  final String? userId;
  final String? appVersion;

  LogModel({
    required this.message,
    required this.type,
    required this.timestamp,
    this.origin,
    this.stackTrace,
    this.userId,
    this.appVersion,
  });

  /// Convierte el modelo a JSON (útil si decides enviarlos al servidor después)
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'origin': origin,
      'stackTrace': stackTrace,
      'userId': userId,
      'appVersion': appVersion,
    };
  }
}
