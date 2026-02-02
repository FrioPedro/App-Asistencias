import 'dart:math';
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

/// Helper para generar Token único (simulación de UUID)
String _generateUniqueToken() {
  final now = DateTime.now().millisecondsSinceEpoch;
  final random = Random().nextInt(1000000); // 0 a 999999
  return 'SESS-$now-$random';
}

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

DateTime _floorToSecond(DateTime dt) =>
    DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);

@collection
class ActivityModel {
  Id id = Isar.autoIncrement;

  /// 🔑 TOKEN DE SESIÓN (Unifica Entrada + Salida)
  @Index(unique: true, replace: true)
  String token = '';

  @Index()
  int? serverId;

  @Index()
  String? documentId;

  /// Cliente (ej: "FRIOPACKING S.A.C.")
  @Index()
  String? client;

  String? description;
  String? collaborator;

  @Index()
  @enumerated
  TaskType task = TaskType.office;

  @Index()
  @enumerated
  AssigmentType activityType = AssigmentType.other;

  // ---------------- DATOS DE ENTRADA (MANDATORIOS) ----------------
  DateTime entryTimestamp = DateTime.fromMillisecondsSinceEpoch(0);
  double? entryLatitude;
  double? entryLongitude;

  // ---------------- DATOS DE SALIDA (OPCIONALES / FUTUROS) ----------------
  DateTime? exitTimestamp;
  double? exitLatitude;
  double? exitLongitude;

  /// Estado de sincronización (Local -> Server)
  @Index()
  bool isSynced = false;

  /// Clave de deduplicación histórica (opcional si usamos Token)
  @Index()
  String dedupKey = '';

  @ignore
  bool get isOpen => exitTimestamp == null;

  @ignore
  bool get isClosed => exitTimestamp != null;

  ActivityModel({
    this.token = '',
    this.serverId,
    this.documentId,
    this.client,
    this.description,
    this.collaborator,
    this.task = TaskType.office,
    this.activityType = AssigmentType.other,

    // Entrada
    required this.entryTimestamp,
    this.entryLatitude,
    this.entryLongitude,

    // Salida (puede venir null)
    this.exitTimestamp,
    this.exitLatitude,
    this.exitLongitude,
    this.isSynced = false,
    this.dedupKey = '',
  }) {
    if (token.isEmpty) {
      token = _generateUniqueToken();
    }
    if (dedupKey.isEmpty) {
      dedupKey = buildDedupKey();
    }
  }

  /// 📥 Construir desde Server (Sesión completa o parcial)
  ActivityModel.fromServer(Map<String, dynamic> json) {
    serverId = json['Identifier'];
    token = json['SessionToken'] ??
        json['Token'] ??
        _generateUniqueToken(); // Server debe devolver Token
    documentId = json['Document'] as String?;
    client = json['Client'] as String?;
    description = json['Description'] as String?;
    collaborator = json['Collaborator'] as String?;

    task = TaskTypeX.fromLabel(json['Task'] as String?);

    final doc = documentId ?? '';
    final prefix = doc.length >= 3 ? doc.substring(0, 3) : '';
    activityType = AssigmentTypeX.fromCode(prefix);

    // Mapeo Espejo
    entryLatitude = (json['EntryLatitude'] as num?)?.toDouble();
    entryLongitude = (json['EntryLongitude'] as num?)?.toDouble();
    entryTimestamp =
        _parseServerTimestamp(json['EntryTimestamp'] ?? json['Timestamp']);

    // Salida (si existe en server)
    if (json['ExitTimestamp'] != null) {
      exitTimestamp = _parseServerTimestamp(json['ExitTimestamp']);
      exitLatitude = (json['ExitLatitude'] as num?)?.toDouble();
      exitLongitude = (json['ExitLongitude'] as num?)?.toDouble();
    }

    isSynced = true; // Viene del server

    dedupKey = buildDedupKey();
  }

  /// 📤 Payload para Sincronización
  Map<String, dynamic> toMarkPayload({
    required int project,
    required String collaboratorId,
    required String zone,
  }) {
    // Formato de fecha server-friendly
    String formatTs(DateTime dt) =>
        dt.toIso8601String().replaceFirst('T', ' ').split('.').first;

    final base = {
      'token': token,
      'project': project,
      'collaborator': collaboratorId,
      'zone': zone,
      'task': task.id,
    };

    if (isClosed) {
      // PAYLOAD CIERRE / SALIDA
      return {
        ...base,
        'motive': 2, // 2 = Salida
        'latitude': exitLatitude,
        'longitude': exitLongitude,
        'timestamp': formatTs(exitTimestamp!),
      };
    } else {
      // PAYLOAD APERTURA / ENTRADA
      return {
        ...base,
        'motive': 1, // 1 = Entrada
        'latitude': entryLatitude,
        'longitude': entryLongitude,
        'timestamp': formatTs(entryTimestamp),
      };
    }
  }

  /// Genera clave única combinando Token + Timestamp base
  String buildDedupKey() {
    return 'token:$token|ts:${_floorToSecond(entryTimestamp).millisecondsSinceEpoch}';
  }
}
