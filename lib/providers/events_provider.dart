import 'package:app_asistencias/domain/assigment/get_assigned.dart';
import 'package:app_asistencias/domain/activity/register_activity.dart';
import 'package:app_asistencias/domain/activity/create_activity.dart';
import 'package:app_asistencias/domain/session/active_session_storage.dart';
import 'package:app_asistencias/models/assigment_model.dart';
import 'package:app_asistencias/models/activity_model.dart';
import 'package:app_asistencias/domain/activity/syncService.dart';

class EventsProvider {
  final ActiveSessionStorage _storage;
  final ActivitySyncService _sync = ActivitySyncService();

  EventsProvider({ActiveSessionStorage? storage})
      : _storage = storage ?? ActiveSessionStorage();

  Future<List<AssigmentModel>> fetchEvents() async {
    await _sync.syncIfPossible();
    return await GetAssigned.fetchAssignment();
  }

  // ✅ CORREGIDO: Agregado DateTime timestamp al tipo de retorno
  Future<({String eventKey, TaskType task, int serverId, DateTime timestamp})?> getActiveSession() {
    return _storage.read();
  }

  /// ✅ Si hay uno activo, lo cierra y luego marca la nueva entrada
  Future<void> startAttendance({
    required AssigmentModel assignment,
    required TaskType task,
  }) async {
    final newServerId = assignment.serverId;
    if (newServerId == null) {
      throw Exception('No se puede iniciar: serverId es null');
    }

    // 1) si hay activo, ciérralo
    final active = await _storage.read();
    if (active != null) {
      await CreateActivity.storeExit(serverId: active.serverId);
      await _storage.clear();
    }

    // 2) marca la nueva entrada
    await ActivityRegistrar.registerEntryWithGPS(
      assignment: assignment,
      task: task,
    );

    // 3) guarda nuevo activo
    final eventKey = assignment.documentId ?? assignment.id.toString();
    await _storage.save(
      eventKey: eventKey,
      task: task,
      serverId: newServerId,
      timestamp: DateTime.now(),
    );

    await _sync.syncIfPossible();
  }

  Future<void> endAttendance({
    required int serverId,
    String? description,
  }) async {
    await ActivityRegistrar.registerExitWithGPS(
      serverId: serverId,
      description: description,
    );
    await _storage.clear();

    await _sync.syncIfPossible();
  }

  Future<void> clearActiveSession() => _storage.clear();
}