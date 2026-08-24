import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';

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

  final int? maxChars;

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
    this.maxChars,
    this.enabled = true,
  });

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
        const SizedBox(height: AppSpacing.sm),
        if (_hasCounter)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) =>
                _buildField(ring: _ringColor(value.text)),
          )
        else
          _buildField(),
        if (_hasCounter) _buildCounter(),
      ],
    );
  }

  Widget _buildField({Color? ring}) {
    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: maxLines,
      maxLength: maxChars,
      enabled: enabled,
      validator: _validate,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        border: ring == null ? null : _ringBorder(ring, 1.5),
        enabledBorder: ring == null ? null : _ringBorder(ring, 1.5),
        focusedBorder: ring == null ? null : _ringBorder(ring, 2),
      ),
    );
  }

  /// El aro repite los tres estados del contador: gris mientras está vacío,
  /// ámbar si empezó y no llega al mínimo, verde al cumplir.
  Color _ringColor(String text) {
    final length = text.trim().length;
    if (length == 0) return AppColors.border;
    return length >= minChars ? AppColors.success : AppColors.warning;
  }

  OutlineInputBorder _ringBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// Contador en vivo para los campos con mínimo de caracteres, para que el
  /// operario vea cuánto le falta en lugar de descubrirlo al intentar enviar.
  Widget _buildCounter() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final length = value.text.trim().length;
          final ok = length >= minChars;
          final empty = length == 0;

          // Mismos tres estados que las descripciones de fotos: gris mientras
          // está vacío, ámbar si empezó y no llega, verde al cumplir. El caso
          // "vacío y obligatorio" es del validador, no de aquí.
          final color = ok
              ? AppColors.success
              : (empty ? AppColors.textSecondary : AppColors.warning);

          final status = empty
              ? Text(
                  'Escribe al menos $minChars letras',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Text.rich(
                  TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: Icon(
                            ok ? Icons.check_circle : Icons.edit_outlined,
                            color: color,
                            size: 15,
                          ),
                        ),
                      ),
                      TextSpan(text: ok ? 'Listo' : 'Escribe un poco más'),
                    ],
                  ),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );

          final counter = Text(
            '$length/${maxChars ?? minChars}',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          );

          // 16 px es donde el mensaje y el contador dejan de caber juntos.
          if (MediaQuery.textScalerOf(context).scale(12) > 16) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                status,
                const SizedBox(height: AppSpacing.xs),
                counter,
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: status),
              const SizedBox(width: AppSpacing.sm),
              counter,
            ],
          );
        },
      ),
    );
  }
}
