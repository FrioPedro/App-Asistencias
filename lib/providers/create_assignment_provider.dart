import '../models/activity_model.dart';

class CreateAssignmentProvider {
  
  /// Simula el envío de la nueva asignación al servidor
  /// Retorna `true` si fue exitoso, `false` si falló.
  Future<bool> createAssignment(ActivityModel assignment) async {
    try {
      // 1. Simular validación y espera de red (2 segundos)
      await Future.delayed(const Duration(seconds: 2));

      // Aquí iría tu llamada HTTP:
      // final response = await http.post(url, body: assignment.toJson());
      
      //print("Asignación creada: ${assignment.toJson()}");

      return true; // Éxito
    } catch (e) {
      print("Error creando asignación: $e");
      return false; // Fallo
    }
  }
}