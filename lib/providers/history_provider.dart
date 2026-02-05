// Para debugPrint
import 'package:app_asistencias/models/activity/activity_model.dart';
import 'package:app_asistencias/domain/activity/get_activity.dart';
import 'package:app_asistencias/domain/activity/syncService.dart';

class HistoryProvider {
  final ActivitySyncService _sync = ActivitySyncService();
  Future<List<ActivityModel>> fetchHistory() async {
    await _sync.syncIfPossible();

    // Reactivada la sincronización con el servidor
    return await GetActivity.getOnlineAndLocalPending();
  }
}
