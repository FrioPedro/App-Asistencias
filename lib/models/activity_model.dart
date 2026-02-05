import 'package:isar/isar.dart';
import 'assigment_model.dart';
import 'taskType_model.dart';
import 'motiveActivity_model.dart';

part 'activity_model.g.dart';

DateTime _parseServerTimestamp(dynamic v) {
  final fallback = DateTime.fromMillisecondsSinceEpoch(0);
  if (v == null) return fallback;
  if (v is DateTime) return v;
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is String) {
    final iso = DateTime.tryParse(v);
    if (iso != null) return iso;
    final fixed = v.replaceFirst(' ', 'T');
    final iso2 = DateTime.tryParse(fixed);
    if (iso2 != null) return iso2;
  }
  return fallback;
}

String _two(int n) => n.toString().padLeft(2, '0');

String _toServerDateTime(DateTime dt) {
  // Formato: "2026-01-30 10:42:53"
  return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} '
      '${_two(dt.hour)}:${_two(dt.minute)}:${_two(dt.second)}';
}

@collection
class ActivityModel {
  Id id = Isar.autoIncrement;

  @Index()
  String? keyGroup;

  @Index()
  int assigmentId;

  @Index()
  String? documentId; // assigment Document ID

  @Index()
  String? client;

  String? description;
  String? collaborator;

  @Index()
  TaskType task = TaskType.office;

  @Index()
  @enumerated
  AssigmentType activityType = AssigmentType.other;

  @Index()
  @enumerated
  MotiveActivity motiveActivity = MotiveActivity.startWork;

  DateTime? timestamp;

  double? latitude;
  double? longitude;

  @Index()
  bool isSynced = false;

  ActivityModel({
    required this.assigmentId,
    this.keyGroup,
    this.documentId,
    this.client,
    this.description,
    this.collaborator,
    this.task = TaskType.office,
    this.activityType = AssigmentType.other,
    this.motiveActivity = MotiveActivity.startWork,
    this.timestamp,
    this.latitude,
    this.longitude,
    this.isSynced = false,
  }) {
    this.keyGroup = keyGroup ?? "";
    this.timestamp = timestamp ?? DateTime.now();
  }

  /// Construir desde Server
  factory ActivityModel.fromServer(Map<String, dynamic> json) {
    final doc = (json['Document'] as String?) ?? '';
    final prefix = doc.length >= 3 ? doc.substring(0, 3) : '';

    final idAssigment = (json['Identifier'] as num?)?.toInt();

    if (idAssigment == null) {
      throw const FormatException('required assigmentId');
    }

    return ActivityModel(
      keyGroup: (json['Keys'] as String?),
      assigmentId: idAssigment,
      documentId: json['Document'] as String,
      description: json['Description'] as String?,
      collaborator: json['Collaborator'] as String?,
      task: TaskTypeX.fromLabel(json['Task'] as String?),
      motiveActivity: MotiveactivityX.fromLabel(json['Motive'] as String?),
      activityType: AssigmentTypeX.fromCode(prefix),
      timestamp: _parseServerTimestamp(json['Timestamp']),
      latitude: (json['Latitude'] as num?)?.toDouble(),
      longitude: (json['Longitude'] as num?)?.toDouble(),
      isSynced: true,
    );
  }

  Map<String, dynamic> toServerPayload(
    String collaborator,
    String zone,
  ) {
    return {
      "project": assigmentId,
      "motive": motiveActivity.id, // int
      "collaborator": collaborator,
      "latitude": latitude,
      "longitude": longitude,
      "timestamp": _toServerDateTime(timestamp ?? DateTime.now()),
      "zone": zone,
      "task": task.id,
    };
  }
}
