import '../models/report_model.dart';

class ReportFormProvider {
  
  /// Envía el reporte al servidor.
  /// Retorna `true` si se guardó correctamente.
  Future<bool> submitReport(ReportModel report) async {
    try {
      // 1. Simular subida de imágenes y datos (2.5 segundos)
      await Future.delayed(const Duration(milliseconds: 2500));

      // Aquí iría tu lógica real:
      // http.post('api/reports', body: report.toJson());
      
      print("Reporte enviado: ${report.toJson()}");

      return true;
    } catch (e) {
      print("Error enviando reporte: $e");
      return false;
    }
  }
}