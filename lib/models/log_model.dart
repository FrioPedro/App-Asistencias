enum LogType { info, warning, error }

class LogModel {
  final String id;
  final String message;
  final LogType type;
  final DateTime timestamp;

  LogModel({
    required this.id,
    required this.message,
    required this.type,
    required this.timestamp,
  });

  /// Convierte el modelo a JSON (útil si decides enviarlos al servidor después)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'type': type.toString().split('.').last, // 'info', 'error', etc.
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '[$type] $timestamp: $message';
  }
}
