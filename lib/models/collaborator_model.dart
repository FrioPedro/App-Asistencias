/// Modelo de colaborador obtenido desde la API.
/// Se usa de forma transitoria para crear asignaciones.
class Collaborator {
  String? document;
  String? name;

  Collaborator({this.document, this.name});

  factory Collaborator.fromJson(Map<String, dynamic> json) {
    return Collaborator(
      document: json['Document'] as String?,
      name: json['Collaborator'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'Document': document,
        'Collaborator': name,
      };

  @override
  String toString() => 'Collaborator(document: $document, name: $name)';
}
