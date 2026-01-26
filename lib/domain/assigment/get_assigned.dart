import 'package:app_asistencias/models/assigment_model.dart';
import 'package:app_asistencias/core/database.dart';
import 'package:app_asistencias/core/enpoinService.dart';
import 'package:isar/isar.dart';

class GetAssigned {
  static Future<List<AssigmentModel>> fetchAssignment() async {
    final isar = await Database.instance();

    List<AssigmentModel> assignmentsOnline = [];
    try {
      assignmentsOnline = await getAssignment();

      if (assignmentsOnline.isNotEmpty) {
        final localAssignmentsActive =
            await isar.assigmentModels.filter().activeEqualTo(true).findAll();

        print(localAssignmentsActive);

        await isar.writeTxn(() async {
          for (final online in assignmentsOnline) {
            // buscar si ya existe por serverId
            final existing = await isar.assigmentModels
                .filter()
                .serverIdEqualTo(online.serverId)
                .findFirst();

            if (existing != null) {
              online.id = existing.id; // ⭐ clave: conservar el id local
            }

            online.active = true; // si viene online, debe quedar activa
            await isar.assigmentModels.put(online);
          }

          final localActive =
              await isar.assigmentModels.filter().activeEqualTo(true).findAll();

          for (final local in localActive) {
            final existsOnline =
                assignmentsOnline.any((o) => o.serverId == local.serverId);
            if (!existsOnline) {
              local.active = false;
              await isar.assigmentModels.put(local);
            }
          }
        });

        print('Sincronización completada');
      } else {
        print('No se recibieron datos del servidor, usando cache local');
      }
    } catch (e) {
      print('Error al obtener datos online: $e');
    }

    final localAssignments =
        await isar.assigmentModels.filter().activeEqualTo(true).findAll();

    return localAssignments;
  }

  static Future<List<AssigmentModel>> getAssignment() async {
    final apiService = EndpointService.instance;

    final response = await apiService.post('/api/assigned');

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.data}');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;

      return data
          .map<AssigmentModel>((json) => AssigmentModel.fromJson(json))
          .toList();
    }
    return [];
  }
}
