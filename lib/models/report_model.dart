class ReportModel {
  final String id;
  final String type;
  final String description;
  final DateTime createdAt;
  // Simulamos las rutas de las imágenes
  final String? beforePhotoPath; 
  final String? afterPhotoPath;

  ReportModel({
    required this.id,
    required this.type,
    required this.description,
    required this.createdAt,
    this.beforePhotoPath,
    this.afterPhotoPath,
  });

  // Simulación para enviar a la API
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'beforePhoto': beforePhotoPath,
    'afterPhoto': afterPhotoPath,
  };
}