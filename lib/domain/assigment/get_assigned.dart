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

        await isar.writeTxn(() async {
          // Guardar o actualizar las asignaciones obtenidas online
          for (final assignmentOnline in assignmentsOnline) {
            await isar.assigmentModels.put(assignmentOnline);
          }

          // Desactivar las que ya no están online
          for (final localAssignment in localAssignmentsActive) {
            final existsOnline = assignmentsOnline.any(
              (onlineAssignment) =>
                  onlineAssignment.serverId == localAssignment.serverId,
            );

            if (!existsOnline) {
              localAssignment.active = false;
              await isar.assigmentModels.put(localAssignment);
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
