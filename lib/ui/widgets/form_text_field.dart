import 'package:flutter/material.dart';

/// Campo de texto reutilizable para los formularios de salida
/// (servicio, taller, etc.).
///
/// Incluye el label en mayúsculas, el fondo tipo card y la validación de
/// obligatoriedad / mínimo de caracteres, revalidando en cada tecla luego de
/// la primera interacción del usuario.
class FormTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  /// Si es `true`, exige contenido no vacío (y respeta [minChars]).
  final bool isRequired;

  final int maxLines;

  /// Mínimo de caracteres exigido cuando [isRequired] es `true`.
  final int minChars;

  /// Se deshabilita mientras el formulario se está enviando.
  final bool enabled;

  const FormTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.isRequired = true,
    this.maxLines = 3,
    this.minChars = 0,
    this.enabled = true,
  });

  static const Color _cardColor = Color(0xFF2C2C2C);
  static const Color _errorRed = Color(0xFFEF5350);

  String? _validate(String? v) {
    if (!isRequired) return null;
    if (v == null || v.trim().isEmpty) {
      return '* Este campo es obligatorio';
    } else if (v.length < minChars) {
      return '* Debes introducir $minChars caracteres como mínimo';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextFormField(
            controller: controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            maxLines: maxLines,
            enabled: enabled,
            validator: _validate,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              border: InputBorder.none,
              errorStyle: const TextStyle(
                color: _errorRed,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 2.2,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
