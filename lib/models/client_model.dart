/// Modelo de cliente obtenido desde la API.
/// Se usa de forma transitoria para crear asignaciones.
class Client {
  String? document;
  String? description;

  Client({this.document, this.description});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      document: json['Document'] as String?,
      description: json['Description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'Document': document,
        'Description': description,
      };

  @override
  String toString() => 'Client(document: $document, description: $description)';
}
