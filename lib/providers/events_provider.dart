import '../models/assigment_model.dart';
import 'package:app_asistencias/domain/assigment/get_assigned.dart';

// Esta clase se encarga SOLO de traer los datos.
class EventsProvider {
  
  Future<List<AssigmentModel>> fetchEvents() async {
    try {

      return await GetAssigned.fetchAssignment();

    } catch (e) {
      print("Error obteniendo eventos: $e");
      return [];
    }
  }
}