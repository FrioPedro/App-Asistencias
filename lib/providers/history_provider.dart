import 'package:app_asistencias/domain/activity/syncService.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:app_asistencias/models/activity_model.dart';
import 'package:isar/isar.dart';
import 'package:app_asistencias/domain/activity/get_activity.dart';

class HistoryProvider {
    final ActivitySyncService _sync = ActivitySyncService();


  Future<List<ActivityModel>> fetchHistory() async {
    await _sync.syncIfPossible();
    return await GetActivity.syncOnlineToLocal();
  }
}
