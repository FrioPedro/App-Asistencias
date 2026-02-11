import 'package:isar/isar.dart';
import '../assigment_model.dart';
import '../taskType_model.dart';
import 'motiveActivity_model.dart';
import '../user/user_zone.dart';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'dart:convert';

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

String makeKeyGroup16({
  required int assigmentId,
  required String collaboratorDocumentId,
  required DateTime timestamp,
}) {
  final ts = timestamp.toUtc().microsecondsSinceEpoch;

  final base = '$assigmentId|$collaboratorDocumentId|$ts';

  final hash = sha256.convert(utf8.encode(base)).bytes;

  // Tomamos 12 bytes = 96 bits
  final first12 = hash.sublist(0, 12);

  // Base64URL sin padding → 16 chars exactos
  return base64UrlEncode(first12).replaceAll('=', '');
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
  String? collaboratordocumentId;

  @enumerated
  UserZone zone = UserZone.centro;

  @Index()
  @enumerated
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
    this.collaboratordocumentId,
    this.zone = UserZone.centro,
    this.task = TaskType.office,
    this.activityType = AssigmentType.other,
    this.motiveActivity = MotiveActivity.startWork,
    this.timestamp,
    this.latitude,
    this.longitude,
    this.isSynced = false,
  }) {
    this.keyGroup = keyGroup ??
        makeKeyGroup16(
            assigmentId: assigmentId,
            collaboratorDocumentId: collaboratordocumentId ?? '',
            timestamp: timestamp ?? DateTime.now());
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
      keyGroup: (json['Keys'] as String?) ?? '',
      assigmentId: idAssigment,
      documentId: json['Document'] as String,
      description: json['Description'] as String?,
      client: json['Client'] as String?,
      collaboratordocumentId: json['collaboratordocumentId'] as String?,
      zone: UserZoneX.fromString(json["Zone"] as String?),
      task: TaskTypeX.fromLabel(json['Task'] as String?),
      motiveActivity: MotiveactivityX.fromLabel(json['Motive'] as String?),
      activityType: AssigmentTypeX.fromCode(prefix),
      timestamp: _parseServerTimestamp(json['Timestamp']),
      latitude: (json['Latitude'] as num?)?.toDouble(),
      longitude: (json['Longitude'] as num?)?.toDouble(),
      isSynced: true,
    );
  }

  Map<String, dynamic> toServerPayload() {
    return {
      "keys": keyGroup,
      "category": 1,
      "project": assigmentId,
      "motive": motiveActivity.id, // int
      "collaborator": collaboratordocumentId,
      "latitude": latitude,
      "longitude": longitude,
      "timestamp": _toServerDateTime(timestamp ?? DateTime.now()),
      "zone": zone.label,
      "task": task.id,
    };
  }

  ActivityModel copyWith({
    int? assigmentId,
    String? keyGroup,
    String? documentId,
    String? client,
    String? description,
    String? collaboratordocumentId,
    UserZone? zone,
    TaskType? task,
    AssigmentType? activityType,
    MotiveActivity? motiveActivity,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    bool? isSynced,
  }) {
    return ActivityModel(
      assigmentId: assigmentId ?? this.assigmentId,
      keyGroup: keyGroup ?? this.keyGroup,
      documentId: documentId ?? this.documentId,
      client: client ?? this.client,
      description: description ?? this.description,
      collaboratordocumentId:
          collaboratordocumentId ?? this.collaboratordocumentId,
      zone: zone ?? this.zone,
      task: task ?? this.task,
      activityType: activityType ?? this.activityType,
      motiveActivity: motiveActivity ?? this.motiveActivity,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
