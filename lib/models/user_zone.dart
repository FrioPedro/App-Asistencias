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

  static UserZone? fromString(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'sur':
        return UserZone.sur;
      case 'centro':
        return UserZone.centro;
      case 'norte':
        return UserZone.norte;
      default:
        return null;
    }
  }

  static List<String> labels() => UserZone.values.map((e) => e.label).toList();
}
