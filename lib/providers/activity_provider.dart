import 'package:app_asistencias/domain/assigment/get_assigned.dart';
import 'package:app_asistencias/domain/activity/register_activity.dart';

import 'package:app_asistencias/domain/session/active_session_storage.dart';
import 'package:app_asistencias/models/assigment_model.dart';
import 'package:app_asistencias/models/activity/activity_model.dart';
import 'package:app_asistencias/domain/activity/syncService.dart';
import 'package:app_asistencias/domain/note/sync_note.dart';
import 'package:app_asistencias/models/taskType_model.dart';
import 'package:app_asistencias/models/user/user_model.dart';
import 'package:app_asistencias/domain/user/get_user.dart';
import 'package:app_asistencias/models/user/user_zone.dart';

class activityProvider {
  final ActiveSessionStorage _storage;
  final ActivitySyncService _sync = ActivitySyncService();
  final NoteSyncService _sync2 = NoteSyncService();
  
  activityProvider({ActiveSessionStorage? storage})
      : _storage = storage ?? ActiveSessionStorage();

  Future<List<AssigmentModel>> fetchactivity() async {
    await _sync.syncIfPossible();
    await _sync2.syncIfPossible();
    return await GetAssigned.fetchAssignment();
  }

  // Agregado DateTime timestamp al tipo de retorno
  Future<({String keyGroup, TaskType task, int serverId, DateTime timestamp})?>
      getActiveSession() {
    return _storage.read();
  }

  /// Si hay uno activo, lo cierra y luego marca la nueva entrada
  Future<void> startAttendance({
    required AssigmentModel assignment,
    required TaskType task,
  }) async {
    final user = await GetUser.getUserLocal();

    final newServerId = assignment.serverId;

    if (newServerId == null) {
      throw Exception('No se puede iniciar: serverId es null');
    }

    if (user == null) {
      throw Exception('No se puede iniciar: usuario no disponible');
    }

    // Capturamos el tiempo BASE
    final now = DateTime.now();
    // Agregamos un pequeño delta a la entrada nueva para asegurar que, al ordenar por fecha,
    // la Entrada de B quede técnicamente "después" de la Salida de A en la BD.
    final entryTime = now.add(const Duration(milliseconds: 100));

    // 1) si hay activo, ciérralo (Hora base)
    final active = await _storage.read();
    if (active != null) {
      await ActivityRegistrar.registerExitWithGPS(
        keyGroup: active.keyGroup,
        timestamp: now,
      );
      await _storage.clear();
    }

    // 2) marca la nueva entrada (Hora base + 100ms)
    final _activity =  await ActivityRegistrar.registerEntryWithGPS(
      collaboratorDocumentId: user.nationalId ?? '',
      userZone: user.zone,
      assignment: assignment,
      task: task,
      timestamp: entryTime,
    );

    // 3) guarda nuevo activo
    final eventKey = _activity.keyGroup;

    if (eventKey == null) {
      throw Exception('No se puede iniciar: eventKey es null');
    }

    await _storage.save(
      keyGroup: eventKey,
      task: task,
      serverId: newServerId,
      timestamp: entryTime,
    );

    await _sync.syncIfPossible();
    await _sync2.syncIfPossible(); // Forzamos envío de notas pendientes
  }

  Future<void> endAttendance({
    required String keyGroup,
  }) async {
    await ActivityRegistrar.registerExitWithGPS(
      keyGroup: keyGroup,
    );
    await _storage.clear();

    await _sync.syncIfPossible();
    await _sync2.syncIfPossible(); // Forzamos envío de notas pendientes
  }

  Future<void> clearActiveSession() => _storage.clear();

  // --- Logic Helpers ---

  bool isCreationAllowed() {
    final now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return true;
    }
    final hour = now.hour;
    // Bloqueado entre 6 AM y 8 PM (20:00)
    if (hour >= 6 && hour < 20) {
      return false;
    }
    return true;
  }

}
