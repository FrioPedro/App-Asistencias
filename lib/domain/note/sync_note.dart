import 'dart:io';
import 'package:dio/dio.dart';
import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/core/enpoinService.dart';
import 'package:app_asistencias/domain/connectivity/network_info.dart';
import 'package:app_asistencias/models/note_model.dart';
import 'package:isar/isar.dart';

class NoteSyncService {
  final NetworkInfo _net;

  NoteSyncService({NetworkInfo? net}) : _net = net ?? NetworkInfo();

  /// Wi-Fi o datos móviles
  Future<void> syncIfPossible() async {
    print('[NOTE_SYNC] syncIfPossible called');

    final connected = await _net.hasConnection();
    print(
        '[NOTE_SYNC] Connectivity: ${connected ? "CONNECTED" : "NO CONNECTION"}');

    if (!connected) {
      print('[NOTE_SYNC] Aborting sync: no connection');
      return;
    }

    await syncPending();
  }

  Future<void> syncPending({int batchSize = 50}) async {
    print('[NOTE_SYNC] syncPending started');

    final isar = await Database.instance();
    final api = EndpointService.instance;

    final allPending = await isar.noteModels
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .sortByTimestamp()
        .findAll();

    print('[NOTE_SYNC] Total pending notes: ${allPending.length}');

    final pending = allPending.take(batchSize).toList();

    if (pending.isEmpty) {
      print('[NOTE_SYNC] No pending notes');
      return;
    }

    print('[NOTE_SYNC] Sending ${pending.length} notes');

    for (final n in pending) {
      print(
          '[NOTE_SYNC] Sending note doc=${n.document}, ts=${n.timestamp}, hasImg=${n.imagePath != null}');

      // 1) marcar uploading
      await isar.writeTxn(() async {
        n.syncStatus = SyncStatus.uploading;
        await isar.noteModels.put(n);
      });

      try {
        final formData = await _buildFormData(n);
        // 🔎 PRINT REAL DEL CONTENIDO
        print('[NOTE_SYNC] FormData fields:');
        for (final f in formData.fields) {
          print('  ${f.key} = ${f.value}');
        }

        print('[NOTE_SYNC] FormData files:');
        for (final f in formData.files) {
          print('  ${f.key} = ${f.value.filename}');
        }

        final res = await api.postFormData(
          '/api/create',
          formData: formData,
        );

        print('[NOTE_SYNC] Response status: ${res.statusCode}');

        if (res.statusCode == 200 || res.statusCode == 201) {
          await isar.writeTxn(() async {
            n.syncStatus = SyncStatus.synced;

            // Si tu backend devuelve Identifier, guardalo
            final data = res.data;
            if (data is Map && data['Identifier'] != null) {
              n.serverId = (data['Identifier'] as num).toInt();
            }

            // Si devuelve Image url, guardala
            if (data is Map && data['Image'] != null) {
              n.imageUrl = data['Image'] as String?;
            }

            // (Opcional) si ya quedó imageUrl, puedes limpiar la ruta local
            // n.imagePath = null;

            await isar.noteModels.put(n);
          });

          print('[NOTE_SYNC] Note marked as synced');
        } else {
          await isar.writeTxn(() async {
            n.syncStatus = SyncStatus.failed;
            await isar.noteModels.put(n);
          });

          print(
              '[NOTE_SYNC] Server returned ${res.statusCode}, note marked failed');
        }
      } catch (e) {
        await isar.writeTxn(() async {
          n.syncStatus = SyncStatus.failed;
          await isar.noteModels.put(n);
        });

        print('[NOTE_SYNC] Error sending note: $e');
      }
    }

    print('[NOTE_SYNC] syncPending finished');
  }

  Future<FormData> _buildFormData(NoteModel n) async {
    final map = <String, dynamic>{
      // ⚠️ Si tu backend espera "project" en vez de "document", cambia esta key:
      'project': n.document,
      'description': n.description,
      if (n.activity != null) 'activity': n.activity,
    };

    if (n.imagePath != null && n.imagePath!.trim().isNotEmpty) {
      final file = File(n.imagePath!);
      if (await file.exists()) {
        map['file'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        );
      } else {
        print('[NOTE_SYNC] imagePath does not exist: ${n.imagePath}');
      }
    }

    return FormData.fromMap(map);
  }
}
