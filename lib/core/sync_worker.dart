// lib/background/sync_worker.dart
import 'package:workmanager/workmanager.dart';
import 'package:app_asistencias/domain/activity/syncService.dart';
import 'package:app_asistencias/domain/overtime/sync_overtime_request.dart';

const String kSyncTask = 'sync_pending_activities';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == kSyncTask) {
      final sync = ActivitySyncService();
      await sync.syncIfPossible(); // ✅ wifi o móvil

      await OvertimeSyncService().pushIfPossible();
    }
    return Future.value(true);
  });
}
