class AssignmentModel {
  final String id;
  final String client;
  final String type;
  final String zone;
  final String description;
  final List<String> collaborators;
  final DateTime createdAt;
  final String status;

  AssignmentModel({
    required this.id,
    required this.client,
    required this.type,
    required this.zone,
    required this.description,
    required this.collaborators,
    required this.createdAt,
    this.status = 'PENDIENTE',
  });

  // Para enviar a la API (Simulación)
  Map<String, dynamic> toJson() => {
    'id': id,
    'client': client,
    'type': type,
    'zone': zone,
    'description': description,
    'collaborators': collaborators,
    'createdAt': createdAt.toIso8601String(),
    'status': status,
  };
}