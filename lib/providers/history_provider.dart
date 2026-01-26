// Para debugPrint
import 'package:app_asistencias/models/activity_model.dart';
import 'package:app_asistencias/domain/activity/get_activity.dart';

class HistoryProvider {
  Future<List<ActivityModel>> fetchHistory() async {
    return await GetActivity.syncOnlineToLocal();
  }
}
