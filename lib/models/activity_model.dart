import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'assigment_model.dart';

part 'activity_model.g.dart';

enum TaskType { office, workshop, service, transport }

extension TaskTypeX on TaskType {
  int get id {
    switch (this) {
      case TaskType.office:
        return 1;
      case TaskType.workshop:
        return 2;
      case TaskType.service:
        return 3;
      case TaskType.transport:
        return 4;
    }
  }

  String get label {
    switch (this) {
      case TaskType.office:
        return 'Oficina';
      case TaskType.workshop:
        return 'Taller';
      case TaskType.service:
        return 'Servicio';
      case TaskType.transport:
        return 'Transporte';
    }
  }

  static TaskType fromId(int? id) {
    switch (id) {
      case 1:
        return TaskType.office;
      case 2:
        return TaskType.workshop;
      case 3:
        return TaskType.service;
      case 4:
        return TaskType.transport;
      default:
        return TaskType.office;
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

  Color get color {
    switch (this) {
      case TaskType.office:
        return Colors.grey;
      case TaskType.workshop:
        return Colors.green;
      case TaskType.service:
        return Colors.blue;
      case TaskType.transport:
        return Colors.orange;
    }
  }
}

/// ✅ Motivo de marcación: 1 entrada, 2 salida
enum MotiveType { entry, exit }

extension MotiveTypeX on MotiveType {
  int get id {
    switch (this) {
      case MotiveType.entry:
        return 1;
      case MotiveType.exit:
        return 2;
    }
  }

  String get label {
    switch (this) {
      case MotiveType.entry:
        return 'Entrada';
      case MotiveType.exit:
        return 'Salida';
    }
  }

  static MotiveType fromId(int? id) {
    switch (id) {
      case 1:
        return MotiveType.entry;
      case 2:
        return MotiveType.exit;
      default:
        return MotiveType.entry;
    }
  }

  /// (Opcional) si el server a veces manda "Entrada"/"Salida" como texto
  static MotiveType? fromLabel(String? label) {
    final s = (label ?? '').trim().toLowerCase();
    if (s == 'inicio de labores') return MotiveType.entry;
    if (s == 'fin de labores') return MotiveType.exit;
    return null;
  }
}

DateTime _parseServerTimestamp(dynamic v) {
  // 👇 fecha antigua por defecto
  final fallback = DateTime.fromMillisecondsSinceEpoch(0);

  if (v == null) return fallback;

  if (v is DateTime) return v;

  if (v is int) {
    return DateTime.fromMillisecondsSinceEpoch(v);
  }

  if (v is String) {
    final iso = DateTime.tryParse(v);
    if (iso != null) return iso;

    final fixed = v.replaceFirst(' ', 'T');
    final iso2 = DateTime.tryParse(fixed);
    if (iso2 != null) return iso2;
  }

  return fallback;
}

@collection
class ActivityModel {
  Id id = Isar.autoIncrement;

  @Index()
  int? serverId;

  @Index()
  String? documentId;

  /// ✅ Cliente (ej: "FRIOPACKING S.A.C.")
  @Index()
  String? client;

  String? description;
  String? collaborator;

  /// Texto que llega del server
  String? motiveText;

  @Index()
  @enumerated
  MotiveType motive = MotiveType.entry;

  @Index()
  @enumerated
  TaskType task = TaskType.office;

  @Index()
  @enumerated
  AssigmentType activityType = AssigmentType.other;

  double? latitude;
  double? longitude;

  late DateTime timestamp;

  @Index(unique: true, replace: true)
  late String dedupKey;

  /// Estado de sincronización
  @Index()
  bool? isSynced;

  ActivityModel({
    this.serverId,
    this.documentId,
    this.client,
    this.description,
    this.collaborator,
    this.motiveText,
    this.motive = MotiveType.entry,
    this.task = TaskType.office,
    this.activityType = AssigmentType.other,
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.isSynced = false,
  }){
    // 🔐 SE CONSTRUYE AUTOMÁTICAMENTE
    dedupKey = buildDedupKey(
                serverId: serverId ?? 0,
                motive: motive,
                task: task,
                activityType: activityType,
              );
  }

  /// ✅ Del server (evento / historial)
  ActivityModel.fromServer(Map<String, dynamic> json) {
    serverId = json['Identifier'];
    documentId = json['Document'] as String?;
    client = json['Client'] as String?; // 👈 NUEVO
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
    timestamp = _parseServerTimestamp(json['Timestamp'] ?? DateTime.now() );

    isSynced = true; // viene del server → sincronizado

    dedupKey = buildDedupKey(
      serverId: serverId ?? 0,
      motive: motive,
      task: task,
      activityType: activityType,
    );
  }

  /// Payload para enviar marcación (NO incluye client)
  Map<String, dynamic> toMarkPayload({
    required int project,
    required String collaboratorId,
    required String zone,
    required DateTime timestamp,
  }) {
    final ts = (timestamp)
        .toIso8601String()
        .replaceFirst('T', ' ')
        .split('.')
        .first;

    return {
      'project': project,
      'motive': motive.id,
      'collaborator': collaboratorId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': ts,
      'zone': zone,
      'task': task.id,
    };
  }

  String _norm(String? s) => (s ?? '').trim().toLowerCase();

  String buildDedupKey({
    required int serverId,
    required MotiveType motive,
    required TaskType task,
    required AssigmentType activityType,
  }) {
    return [
      'id:${_norm(serverId.toString())}',
      'm:${motive.index}',
      't:${task.index}',
      'a:${activityType.index}',
      'dt:${timestamp.toString()}',
    ].join('|');
  }
}
