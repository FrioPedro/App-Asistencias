import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../core/enpoinService.dart';
import '../models/report_model.dart';

class ReportFormProvider {
  final EndpointService _api = EndpointService.instance;

  /// Envía el reporte general de actividades (usado en ReportFormScreen).
  /// Retorna `true` si se guardó correctamente.
  Future<bool> submitReport(ReportModel report) async {
    try {
      // Por ahora mantenemos la simulación para este flujo específico
      // o podrías implementarlo real aquí.
      await Future.delayed(const Duration(milliseconds: 2000));
      debugPrint("Reporte general enviado: ${report.toJson()}");
      return true;
    } catch (e) {
      debugPrint("Error enviando reporte general: $e");
      return false;
    }
  }

  /// Envía el reporte de salida de servicio con múltiples fotos y datos adicionales (Multipart).
  Future<bool> submitServiceExitReport({
    required int serverId,
    required String incidencias,
    required String conclusiones,
    required String recomendaciones,
    required String acciones,
    required List<AssetEntity> photosAntes,
    required List<AssetEntity> photosDespues,
  }) async {
    try {
      final formData = FormData();

      // Agregar campos de texto
      formData.fields.addAll([
        MapEntry('serverId', serverId.toString()),
        MapEntry('incidencias', incidencias.trim()),
        MapEntry('conclusiones', conclusiones.trim()),
        MapEntry('recomendaciones', recomendaciones.trim()),
        MapEntry('acciones', acciones.trim()),
      ]);

      // Procesar fotos ANTES
      for (int i = 0; i < photosAntes.length; i++) {
        final File? file = await photosAntes[i].file;
        if (file != null) {
          formData.files.add(MapEntry(
            'fotos_antes',
            await MultipartFile.fromFile(
              file.path,
              filename:
                  'antes_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ));
        }
      }

      // Procesar fotos DESPUÉS
      for (int i = 0; i < photosDespues.length; i++) {
        final File? file = await photosDespues[i].file;
        if (file != null) {
          formData.files.add(MapEntry(
            'fotos_despues',
            await MultipartFile.fromFile(
              file.path,
              filename:
                  'despues_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ));
        }
      }

      // Enviar al servidor
      final response = await _api.postFormData(
        '/api/servicios/reporte',
        formData: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error en ReportFormProvider.submitServiceExitReport: $e');
      return false;
    }
  }
}
