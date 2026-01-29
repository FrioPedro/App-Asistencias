import 'package:isar/isar.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
part 'note_model.g.dart';

enum SyncStatus { pending, uploading, synced, failed }

@collection
class NoteModel {
  Id id = Isar.autoIncrement;

  //@Index(unique: true, replace: true)
  int? serverId; 
  @Index()
  late String document;

  late String description;

  String? imagePath;
  String? imageUrl;

  String? activity; 
  String? collaborator;

  late DateTime timestamp;

  @Index()
  @enumerated
  SyncStatus syncStatus = SyncStatus.pending;

  @Index(unique: true, replace: true)
  late String dedupKey;

  NoteModel({
    this.serverId,
    required this.document,
    required this.description,
    this.imagePath,
    this.imageUrl,
    this.activity,
    this.collaborator,
    required this.timestamp,
    this.syncStatus = SyncStatus.pending,
  }) {
    dedupKey = buildDedupKey(
      document: document,
      description: description, 
      timestamp: timestamp,
    );
  }


  NoteModel.fromServer(Map<String, dynamic> json) {
    serverId = (json['Identifier'] as num?)?.toInt();
    document = (json['Document'] as String?) ?? '';
    description = (json['Description'] as String?) ?? '';
    imageUrl = json['Image'] as String?;
    activity = json['Activity'] as String?;
    collaborator = json['Collaborator'] as String?;
    timestamp = _parseServerTimestamp(json['Timestamp']);

    syncStatus = SyncStatus.synced;

    dedupKey = buildDedupKey(
      document: document,
      description: description,
      timestamp: timestamp
    );
  }

  // ---------------- helpers ----------------

  String _norm(String s) => s.trim().toLowerCase();

String buildDedupKey({
  required String document,
  required String description,
  required DateTime timestamp,
  String? imagePath,
}) {
  final base = [
    _norm(document),
    _norm(description),
    timestamp.toIso8601String(), // o recortado a minuto si quieres
    if (imagePath != null) _norm(imagePath),
  ].join('|');

  return sha1.convert(utf8.encode(base)).toString().substring(0, 20);
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
}
