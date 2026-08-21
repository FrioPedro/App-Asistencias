import 'package:flutter/material.dart';

/// Paleta única de la app. Cada color existe una sola vez y se referencia por su
/// rol, no por su valor. Si un color no está acá, no debe usarse.
class AppColors {
  AppColors._();

  static const Color bg = Color(0xFF18191D);
  static const Color surface = Color(0xFF2C2C2C);
  static const Color surfaceAlt = Color(0xFF1F1F1F);

  /// Un paso por encima de [surface]: botones y chips neutros que van *sobre*
  /// una superficie y tienen que seguir leyéndose como tocables.
  static const Color surfaceRaised = Color(0xFF424242);

  /// Fondo de las tablas de datos. Es el unico color translucido de la paleta:
  /// se compone sobre el fondo que tenga detras, asi que la tabla acompana a su
  /// contenedor en vez de fijar un gris propio.
  static const Color surfaceTable = Color(0x1AFFFFFF);

  static const Color primary = Color(0xFF2E60C4);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB300);
  static const Color danger = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  static const Color textPrimary = Colors.white;

  /// #9E9E9E es el gris más oscuro que mantiene 4.5:1 (WCAG AA) sobre los tres
  /// fondos de la app; #757575 falla contra [surface].
  static const Color textSecondary = Color(0xFF9E9E9E);

  /// Entre [textPrimary] y [textSecondary]: metadatos que acompañan a un
  /// título y deben leerse menos que él, pero más que el cuerpo secundario.
  static const Color textMeta = Color(0xFFBDBDBD);

  /// Solo para iconografía decorativa y estados vacíos, donde aplica el umbral
  /// de 3:1 y no el de 4.5:1.
  static const Color iconMuted = Color(0xFF757575);

  static const Color border = Color(0xFF616161);

  /// Más oscuro que [surfaceRaised] para que un botón inhabilitado nunca se lea
  /// como más prominente que uno activo.
  static const Color disabled = Color(0xFF303136);

  /// Texto e iconos sobre fills de [success] y [warning], que son demasiado
  /// claros para blanco (1.79:1 sobre ámbar).
  static const Color onAccent = Color(0xFF1A1A1A);
}
