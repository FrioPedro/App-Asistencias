class UserModel {
  final String name;
  final String document;
  final String zone;
  final String? photoUrl; // Opcional, por si en el futuro hay foto

  UserModel({
    required this.name,
    required this.document,
    required this.zone,
    this.photoUrl,
  });
}