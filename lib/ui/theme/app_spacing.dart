/// Escala de espaciado. Los valores intermedios que existían en el árbol
/// (10, 14, 20, 28, 30) se mapean al paso más cercano de esta escala.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Padding horizontal del contenido de cualquier pantalla o sheet.
  static const double gutter = 24;

  /// Alto único de los CTA primarios.
  static const double ctaHeight = 56;
}
