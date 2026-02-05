import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_asistencias/models/activity/activity_model.dart';
import 'package:app_asistencias/models/taskType_model.dart';

class ActiveSessionStorage {
  static const _kActivekeyGroup = 'active_event_key';
  static const _kActiveTaskId = 'active_task_id';
  static const _kActiveServerId = 'active_server_id';
  // 1. Nueva clave para la hora
  static const _kActiveTimestamp = 'active_timestamp'; 

  // 2. Actualizamos el retorno para incluir 'timestamp'
  Future<({String keyGroup, TaskType task, int serverId, DateTime timestamp})?> read() async {
    final sp = await SharedPreferences.getInstance();

    final key = sp.getString(_kActivekeyGroup);
    final taskId = sp.getInt(_kActiveTaskId);
    final serverId = sp.getInt(_kActiveServerId);
    final tsMillis = sp.getInt(_kActiveTimestamp); // Leemos milisegundos

    if (key == null || taskId == null || serverId == null || tsMillis == null) {
      return null;
    }

    return (
      keyGroup: key,
      task: TaskTypeX.fromId(taskId),
      serverId: serverId,
      timestamp: DateTime.fromMillisecondsSinceEpoch(tsMillis), // Convertimos a DateTime
    );
  }

  Future<void> save({
    required String keyGroup,
    required TaskType task,
    required int serverId,
    required DateTime timestamp, // 3. Pedimos la fecha al guardar
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kActivekeyGroup, keyGroup);
    await sp.setInt(_kActiveTaskId, task.id);
    await sp.setInt(_kActiveServerId, serverId);
    await sp.setInt(_kActiveTimestamp, timestamp.millisecondsSinceEpoch); // Guardamos milisegundos
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kActivekeyGroup);
    await sp.remove(_kActiveTaskId);
    await sp.remove(_kActiveServerId);
    await sp.remove(_kActiveTimestamp); // Limpiamos fecha
  }
}