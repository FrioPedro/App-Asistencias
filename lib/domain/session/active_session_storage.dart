import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_asistencias/models/activity_model.dart';

class ActiveSessionStorage {
  static const _kActiveEventKey = 'active_event_key';
  static const _kActiveTaskId = 'active_task_id';
  static const _kActiveServerId = 'active_server_id';

  Future<({String eventKey, TaskType task, int serverId})?> read() async {
    final sp = await SharedPreferences.getInstance();

    final key = sp.getString(_kActiveEventKey);
    final taskId = sp.getInt(_kActiveTaskId);
    final serverId = sp.getInt(_kActiveServerId);

    if (key == null || taskId == null || serverId == null) return null;

    return (
      eventKey: key,
      task: TaskTypeX.fromId(taskId),
      serverId: serverId,
    );
  }

  Future<void> save({
    required String eventKey,
    required TaskType task,
    required int serverId,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kActiveEventKey, eventKey);
    await sp.setInt(_kActiveTaskId, task.id);
    await sp.setInt(_kActiveServerId, serverId);
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kActiveEventKey);
    await sp.remove(_kActiveTaskId);
    await sp.remove(_kActiveServerId);
  }
}
