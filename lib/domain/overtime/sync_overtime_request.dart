import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/core/enpoinService.dart';
import 'package:app_asistencias/domain/connectivity/network_info.dart';
import 'package:app_asistencias/models/assigment_model.dart';
import 'package:app_asistencias/models/log_model.dart';
import 'package:app_asistencias/models/note_model.dart' show SyncStatus;
import 'package:app_asistencias/models/overtime_request_model.dart';
import 'package:app_asistencias/providers/log_provider.dart';
import 'package:isar/isar.dart';

/// Sincronizacion de solicitudes de horas extra.
///
/// El listado solo responde por proyecto, asi que el pull hace una consulta
/// por cada asignacion activa del usuario.
class OvertimeSyncService {
  static const String createEndpoint = '/api/extras/create';
  static const String listEndpoint = '/api/extras';

  final NetworkInfo _net;

  OvertimeSyncService({NetworkInfo? net}) : _net = net ?? NetworkInfo();

  Future<void> syncIfPossible() async {
    if (!await _ensureConnection()) return;

    await pushPending();
    await pullRemote();
  }

  /// Solo sube. Es lo que corre el worker de background: el pull hace un
  /// request por proyecto activo y no vale gastarlo cada 15 minutos.
  Future<void> pushIfPossible() async {
    if (!await _ensureConnection()) return;

    await pushPending();
  }

  Future<bool> _ensureConnection() async {
    final connected = await _net.hasConnection();

    if (!connected) {
      LogProvider.log(
        'Sincronizacion de horas extra abortada: Sin conexion',
        type: LogType.warning,
        origin: 'OvertimeSyncService',
      );
    }

    return connected;
  }

  /// Sube las solicitudes que nunca llegaron al servidor. `failed` marca el
  /// ultimo intento, no un estado final: vuelve a la cola en cada barrido.
  Future<void> pushPending({int batchSize = 50}) async {
    final isar = await Database.instance();
    final api = EndpointService.instance;

    final allPending = await isar.overtimeRequestModels
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .or()
        .syncStatusEqualTo(SyncStatus.failed)
        .sortByStart()
        .findAll();

    final pending = allPending.take(batchSize).toList();
    if (pending.isEmpty) return;

    LogProvider.log(
      'Sincronizacion de horas extra iniciada: ${pending.length} solicitudes',
      type: LogType.info,
      origin: 'OvertimeSyncService',
    );

    for (final r in pending) {
      await isar.writeTxn(() async {
        r.syncStatus = SyncStatus.uploading;
        await isar.overtimeRequestModels.put(r);
      });

      try {
        final payload = buildPayload(r);
        print('[OVERTIME_SYNC] POST $createEndpoint $payload');

        final res = await api.post(createEndpoint, data: payload);

        final ok = res.statusCode == 200 || res.statusCode == 201;

        print('[OVERTIME_SYNC] status=${res.statusCode} body=${res.data}');

        await isar.writeTxn(() async {
          r.syncStatus = ok ? SyncStatus.synced : SyncStatus.failed;
          await isar.overtimeRequestModels.put(r);
        });

        LogProvider.log(
          ok
              ? 'Solicitud de horas extra sincronizada (ID local: ${r.id})'
              : 'Error al sincronizar horas extra: servidor retorno ${res.statusCode}',
          type: ok ? LogType.info : LogType.error,
          origin: 'OvertimeSyncService',
        );
      } catch (e) {
        print('[OVERTIME_SYNC] Error sending request: $e');

        await isar.writeTxn(() async {
          r.syncStatus = SyncStatus.failed;
          await isar.overtimeRequestModels.put(r);
        });

        LogProvider.log(
          'Error critico al sincronizar horas extra: $e',
          type: LogType.error,
          origin: 'OvertimeSyncService',
        );
      }
    }
  }

  /// Trae el estado de las solicitudes, un request por asignacion activa.
  Future<void> pullRemote() async {
    final isar = await Database.instance();

    final assignments =
        await isar.assigmentModels.filter().activeEqualTo(true).findAll();

    final projectIds = assignments
        .map((a) => a.serverId)
        .where((id) => id != 0)
        .toSet()
        .toList();

    if (projectIds.isEmpty) return;

    for (final projectId in projectIds) {
      await _pullProject(projectId, isar);
    }
  }

  /// Un proyecto que falla no corta la sincronizacion de los demas.
  Future<void> _pullProject(int projectId, Isar isar) async {
    final api = EndpointService.instance;

    try {
      final res = await api.post(
        listEndpoint,
        data: <String, dynamic>{'project': projectId},
      );

      if (res.statusCode != 200) return;

      final data = res.data;
      final rawList = data is List
          ? data
          : (data is Map && data['Data'] is List ? data['Data'] as List : null);

      if (rawList == null || rawList.isEmpty) return;

      final remote = rawList
          .whereType<Map>()
          .map((e) => OvertimeRequestModel.fromServer(
                Map<String, dynamic>.from(e),
                projectId: projectId,
              ))
          .toList();

      await isar.writeTxn(() async {
        for (final r in remote) {
          final existing = await isar.overtimeRequestModels
              .filter()
              .dedupKeyEqualTo(r.dedupKey)
              .findFirst();

          if (existing != null) {
            r.id = existing.id;
            // El servidor no guarda el envio: se conserva el sello local.
            r.submittedAt = existing.submittedAt;
          }

          await isar.overtimeRequestModels.put(r);
        }
      });
    } catch (e) {
      LogProvider.log(
        'Error al traer horas extra del proyecto $projectId: $e',
        type: LogType.error,
        origin: 'OvertimeSyncService',
      );
    }
  }

  static Map<String, dynamic> buildPayload(OvertimeRequestModel r) {
    return <String, dynamic>{
      'project': r.projectId,
      'description': r.justification,
      'initial': serverDateTime(r.start),
      'finish': serverDateTime(r.end),
    };
  }

  /// El create espera `dd/MM/yyyy HH:mm`, no ISO.
  static String serverDateTime(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');

    return '${two(d.day)}/${two(d.month)}/${d.year} '
        '${two(d.hour)}:${two(d.minute)}';
  }
}
