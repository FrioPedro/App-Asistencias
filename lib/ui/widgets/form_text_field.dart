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
  static const Color _okGreen = Color(0xFF4CAF50);
  static const Color _pendingAmber = Color(0xFFFFB300);

  /// Los campos con mínimo de caracteres muestran el contador en vivo, que ya
  /// dice cuánto falta. En ellos el mensaje del validador se oculta para no
  /// repetir la misma información en dos lugares.
  bool get _hasCounter => isRequired && minChars > 0;

  String? _validate(String? v) {
    if (!isRequired) return null;
    final text = (v ?? '').trim();
    if (text.isEmpty) {
      return '* Este campo es obligatorio';
    } else if (text.length < minChars) {
      // Ya escribió algo: el aviso pasa a ser del contador, que dice cuánto
      // falta. El validador se queda solo con bloquear el envío, así que
      // devuelve un mensaje vacío en vez de repetir la misma información.
      return _hasCounter
          ? ''
          : '* Debes introducir $minChars caracteres como mínimo';
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
        if (_hasCounter) _buildCounter(),
      ],
    );
  }

  /// Contador en vivo para los campos con mínimo de caracteres, para que el
  /// operario vea cuánto le falta en lugar de descubrirlo al intentar enviar.
  Widget _buildCounter() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final length = value.text.trim().length;
          final ok = length >= minChars;
          final empty = length == 0;

          // Mismos tres estados que las descripciones de fotos: gris mientras
          // está vacío, ámbar si empezó y no llega, verde al cumplir. El caso
          // "vacío y obligatorio" es del validador, no de aquí.
          final color =
              ok ? _okGreen : (empty ? Colors.grey[500] : _pendingAmber);

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (empty)
                Text(
                  'Escribe al menos $minChars letras',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Row(
                  children: [
                    Icon(
                      ok ? Icons.check_circle : Icons.edit_outlined,
                      color: color,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ok ? 'Listo' : 'Escribe un poco más',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              Text(
                '$length/$minChars',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
