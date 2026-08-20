/// Escala de espaciado. Es la única fuente de márgenes y paddings: todo valor
/// intermedio que existía en el árbol (2, 5, 6, 10, 14, 18, 20, 28, 30, 40, 50,
/// 60, 80) cae al paso más cercano de esta escala.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Padding horizontal del contenido de cualquier pantalla o sheet.
  static const double gutter = 24;

  /// Alto único de los CTA primarios.
  static const double ctaHeight = 56;
}
