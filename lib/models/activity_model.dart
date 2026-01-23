import 'package:isar/isar.dart';
import 'assigment_model.dart';

part 'activity_model.g.dart';

enum TaskType { office, workshop, service, transport }

extension TaskTypeX on TaskType {
  int get id {
    switch (this) {
      case TaskType.office: return 1;
      case TaskType.workshop: return 2;
      case TaskType.service: return 3;
      case TaskType.transport: return 4;
    }
  }

  String get label {
    switch (this) {
      case TaskType.office: return 'Oficina';
      case TaskType.workshop: return 'Taller';
      case TaskType.service: return 'Servicio';
      case TaskType.transport: return 'Transporte';
    }
  }

  static TaskType fromId(int? id) {
    switch (id) {
      case 1: return TaskType.office;
      case 2: return TaskType.workshop;
      case 3: return TaskType.service;
      case 4: return TaskType.transport;
      default: return TaskType.office;
    }
  }

  /// Server -> enum por texto ("Servicio", "Oficina", etc.)
  static TaskType fromLabel(String? label) {
    final s = (label ?? '').trim().toLowerCase();
    if (s == 'oficina') return TaskType.office;
    if (s == 'taller') return TaskType.workshop;
    if (s == 'servicio') return TaskType.service;
    if (s == 'transporte') return TaskType.transport;
    return TaskType.office;
  }
}

/// ✅ Motivo de marcación: 1 entrada, 2 salida
enum MotiveType { entry, exit }

extension MotiveTypeX on MotiveType {
  int get id {
    switch (this) {
      case MotiveType.entry: return 1;
      case MotiveType.exit: return 2;
    }
  }

  String get label {
    switch (this) {
      case MotiveType.entry: return 'Entrada';
      case MotiveType.exit: return 'Salida';
    }
  }

  static MotiveType fromId(int? id) {
    switch (id) {
      case 1: return MotiveType.entry;
      case 2: return MotiveType.exit;
      default: return MotiveType.entry;
    }
  }

  /// (Opcional) si el server a veces manda "Entrada"/"Salida" como texto
  static MotiveType? fromLabel(String? label) {
    final s = (label ?? '').trim().toLowerCase();
    if (s == 'entrada') return MotiveType.entry;
    if (s == 'salida') return MotiveType.exit;
    return null;
  }
}

/// Soporta:
/// - "2025-10-29T15:19:21"
/// - "2025-05-26 10:42:53"
DateTime _parseServerTimestamp(dynamic v) {
  if (v == null) return DateTime.now();
  if (v is DateTime) return v;
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);

  if (v is String) {
    final iso = DateTime.tryParse(v);
    if (iso != null) return iso;

    final fixed = v.replaceFirst(' ', 'T');
    final iso2 = DateTime.tryParse(fixed);
    if (iso2 != null) return iso2;
  }

  return DateTime.now();
}

@collection
class ActivityModel {
  Id id = Isar.autoIncrement;

  @Index()
  int? serverId;

  @Index()
  String? documentId;

  String? description;
  String? collaborator;

  /// Texto que llega del server
  String? motiveText;

  /// Motivo para marcación (1 entrada / 2 salida)
  @Index()
  @enumerated
  MotiveType motive = MotiveType.entry;

  /// Task (Oficina, Taller, Servicio, Transporte)
  @Index()
  @enumerated
  TaskType task = TaskType.office;

  /// Tipo derivado del documento (EMG, PRY, etc.)
  @Index()
  @enumerated
  AssigmentType activityType = AssigmentType.other;

  double? latitude;
  double? longitude;

  @Index()
  DateTime timestamp = DateTime.now();

  /// ✅ SINCRONIZACIÓN
  @Index()
  bool isSynced = false; // 👈 siempre false por defecto

  ActivityModel({
    this.serverId,
    this.documentId,
    this.description,
    this.collaborator,
    this.motiveText,
    this.motive = MotiveType.entry,
    this.task = TaskType.office,
    this.activityType = AssigmentType.other,
    this.latitude,
    this.longitude,
    DateTime? timestamp,
    bool? isSynced,
  })  : timestamp = timestamp ?? DateTime.now(),
        isSynced = isSynced ?? false;

  /// Del server → esto YA está sincronizado
  ActivityModel.fromServer(Map<String, dynamic> json) {
    documentId = json['Document'] as String?;
    description = json['Description'] as String?;
    collaborator = json['Collaborator'] as String?;
    motiveText = json['Motive'] as String?;

    final maybeMotive = MotiveTypeX.fromLabel(motiveText);
    if (maybeMotive != null) motive = maybeMotive;

    task = TaskTypeX.fromLabel(json['Task'] as String?);

    final doc = documentId ?? '';
    final prefix = doc.length >= 3 ? doc.substring(0, 3) : '';
    activityType = AssigmentTypeX.fromCode(prefix);

    latitude = (json['Latitude'] as num?)?.toDouble();
    longitude = (json['Longitude'] as num?)?.toDouble();
    timestamp = _parseServerTimestamp(json['Timestamp']);

    isSynced = true; // 👈 viene del server → ya sincronizado
  }
}
