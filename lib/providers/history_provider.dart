// Para debugPrint
import 'package:app_asistencias/models/activity_model.dart';
import 'package:app_asistencias/domain/activity/get_activity.dart';
import 'package:app_asistencias/domain/activity/syncService.dart';

class HistoryProvider {
  final ActivitySyncService _sync = ActivitySyncService();
  Future<List<ActivityModel>> fetchHistory() async {
    await GetActivity.syncOnline();

    await _sync.syncIfPossible();
    // TEMPORAL: Desactivamos la bajada de datos del servidor porque está corrompiendo/borrando
    // los datos locales recientes con timestamps erróneos o estados antiguos.
    // return await GetActivity.syncOnlineToLocal();
    return await GetActivity.getLocalData();
  }
}
