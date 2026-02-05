enum UserZone {
  sur,
  centro,
  norte,
}

extension UserZoneX on UserZone {
  String get label {
    switch (this) {
      case UserZone.sur:
        return 'Sur';
      case UserZone.centro:
        return 'Centro';
      case UserZone.norte:
        return 'Norte';
    }
  }

  /// Convierte un String (ej: "sur", "Sur") al Enum correspondiente
  static UserZone fromString(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'sur':
        return UserZone.sur;
      case 'centro':
        return UserZone.centro;
      case 'norte':
        return UserZone.norte;
      default:
        return UserZone.centro;
    }
  }

  /// Retorna la lista de etiquetas para usar en Dropdowns ['Sur', 'Centro', 'Norte']
  static List<String> labels() => UserZone.values.map((e) => e.label).toList();
}