import 'package:isar/isar.dart';
import 'assigment_model.dart';

part 'activity_model.g.dart';

enum TaskType {
  office,     // 1
  workshop,   // 2
  service,    // 3
  transport,  // 4
}

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

  /// ✅ Server -> enum por texto ("Servicio", "Oficina", etc.)
  static TaskType fromLabel(String? label) {
    final s = (label ?? '').trim().toLowerCase();
    if (s == 'Oficina') return TaskType.office;
    if (s == 'Taller') return TaskType.workshop;
    if (s == 'Servicio') return TaskType.service;
    if (s == 'Transporte') return TaskType.transport;
    return TaskType.office;
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
    // ISO directo
    final iso = DateTime.tryParse(v);
    if (iso != null) return iso;

    // "yyyy-MM-dd HH:mm:ss" -> convertir a ISO
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
  String? documentId;

  String? description;

  String? collaborator;

  String? motive;

  TaskType task = TaskType.office;

  AssigmentType activityType = AssigmentType.other;

  double? latitude;
  double? longitude;

  DateTime timestamp = DateTime.now();

  final assigment = IsarLink<AssigmentModel>();

  ActivityModel({
    this.documentId,
    this.description,
    this.collaborator,
    this.motive,
    this.task = TaskType.office,
    this.activityType = AssigmentType.other,
    this.latitude,
    this.longitude,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// ✅ Del server (evento/registro)
  ActivityModel.fromServer(Map<String, dynamic> json) {
    final doc = (json['Document'] ?? '') as String;
    documentId = doc;
    description = json['Description'] as String?;
    collaborator = json['Collaborator'] as String?;
    motive = json['Motive'] as String?;

    // task llega como texto: "Servicio"
    task = TaskTypeX.fromLabel(json['Task'] as String?);

    // tipo por prefijo del document: "EMG"
    final prefix = doc.length >= 3 ? doc.substring(0, 3) : '';
    activityType = AssigmentTypeX.fromCode(prefix);

    latitude = (json['Latitude'] as num?)?.toDouble();
    longitude = (json['Longitude'] as num?)?.toDouble();
    timestamp = _parseServerTimestamp(json['Timestamp']);
  }

  /// ✅ Payload para enviar marcación
  /// {
  ///   "project": 771,
  ///   "motive": 1,
  ///   "collaborator": "740854676",
  ///   "latitude": -14,
  ///   "longitude": -14,
  ///   "timestamp": "2025-05-26 10:42:53",
  ///   "zone": "Sur",
  ///   "task": 1
  /// }
  Map<String, dynamic> toMarkPayload({
    required int project,
    required int motiveId,
    required String collaboratorId,
    required String zone,
  }) {
    // server quiere "yyyy-MM-dd HH:mm:ss"
    final ts = timestamp.toIso8601String().replaceFirst('T', ' ').split('.').first;

    return {
      'project': project,
      'motive': motiveId,
      'collaborator': collaboratorId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': ts,
      'zone': zone,
      'task': task.id, // ✅ int 1..4
    };
  }
}
