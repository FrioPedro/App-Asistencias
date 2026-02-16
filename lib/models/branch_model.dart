/// Modelo de sucursal/zona obtenido desde la API.
/// Se usa en la vista de creación de asignaciones para seleccionar la zona.
class BranchModel {
  int? serverId;
  String name;

  BranchModel({this.serverId, required this.name});

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      serverId: json['Identifier'] as int?,
      name: (json['Name'] as String?) ?? 'Sin nombre',
    );
  }

  Map<String, dynamic> toJson() => {
        'Identifier': serverId,
        'Name': name,
      };

  @override
  String toString() => 'BranchModel(serverId: $serverId, name: $name)';
}
