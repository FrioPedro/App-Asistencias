import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_radius.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';

import 'package:app_asistencias/ui/screens/overtime/overtime_format.dart';

/// Selector de hora por ruedas: Hora | Minuto | AM/PM.
///
/// Devuelve los minutos desde medianoche, o `null` si el operario cancela.
class OvertimeTimePickerSheet extends StatefulWidget {
  final String title;

  /// Valor inicial en minutos desde medianoche.
  final int initialMinutes;

  const OvertimeTimePickerSheet({
    super.key,
    required this.title,
    required this.initialMinutes,
  });

  /// Paso de la rueda de minutos: 5 deja 12 posiciones en vez de 60.
  static const int minuteStep = 5;

  static const double _itemExtent = 52;

  /// Abre el selector y devuelve los minutos elegidos, o `null` si se cancela.
  static Future<int?> show(
    BuildContext context, {
    required String title,
    required int initialMinutes,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => OvertimeTimePickerSheet(
        title: title,
        initialMinutes: initialMinutes,
      ),
    );
  }

  @override
  State<OvertimeTimePickerSheet> createState() =>
      _OvertimeTimePickerSheetState();
}

class _OvertimeTimePickerSheetState extends State<OvertimeTimePickerSheet> {
  /// 1..12 tal como se lee en la rueda.
  late int _hour12;

  /// Minuto ya alineado al paso de la rueda.
  late int _minute;

  /// `false` = a.m., `true` = p.m.
  late bool _isPm;

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;
  late final FixedExtentScrollController _meridiemController;

  static const List<int> _hours = [
    12,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
  ];

  List<int> get _minutes => [
        for (var m = 0; m < 60; m += OvertimeTimePickerSheet.minuteStep) m,
      ];

  @override
  void initState() {
    super.initState();
    _applyMinutes(widget.initialMinutes);

    _hourController =
        FixedExtentScrollController(initialItem: _hours.indexOf(_hour12));
    _minuteController =
        FixedExtentScrollController(initialItem: _minutes.indexOf(_minute));
    _meridiemController =
        FixedExtentScrollController(initialItem: _isPm ? 1 : 0);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _meridiemController.dispose();
    super.dispose();
  }

  /// Traduce minutos desde medianoche al estado de las tres ruedas, alineando
  /// el minuto a [OvertimeTimePickerSheet.minuteStep].
  void _applyMinutes(int totalMinutes) {
    final normalized = totalMinutes % (24 * 60);
    final hour24 = normalized ~/ 60;

    _isPm = hour24 >= 12;
    _hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    const step = OvertimeTimePickerSheet.minuteStep;
    _minute = ((normalized % 60) ~/ step) * step;
  }

  int get _selectedMinutes {
    final hour24 = _isPm
        ? (_hour12 == 12 ? 12 : _hour12 + 12)
        : (_hour12 == 12 ? 0 : _hour12);
    return hour24 * 60 + _minute;
  }

  /// Salta a la hora actual.
  void _setNow() {
    final now = DateTime.now();
    setState(() => _applyMinutes(now.hour * 60 + now.minute));

    _hourController.animateToItem(
      _hours.indexOf(_hour12),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    _minuteController.animateToItem(
      _minutes.indexOf(_minute),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    _meridiemController.animateToItem(
      _isPm ? 1 : 0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(color: AppColors.surface, height: 1),
            _buildCurrentValue(),
            _buildColumnLabels(),
            _buildWheels(),
            const SizedBox(height: AppSpacing.sm),
            _buildActions(),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close,
                color: AppColors.textSecondary, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentValue() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Text(
              OvertimeFormat.time(_selectedMinutes),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: _setNow,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            ),
            child: const Text(
              'AHORA',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnLabels() {
    Widget label(String text) => Expanded(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          label('HORA'),
          label('MINUTO'),
          label('AM/PM'),
        ],
      ),
    );
  }

  Widget _buildWheels() {
    return SizedBox(
      height: OvertimeTimePickerSheet._itemExtent * 5,
      child: Stack(
        children: [
          Center(
            child: Container(
              height: OvertimeTimePickerSheet._itemExtent,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildWheel(
                  controller: _hourController,
                  itemCount: _hours.length,
                  labelAt: (i) => '${_hours[i]}',
                  isSelected: (i) => _hours[i] == _hour12,
                  onSelected: (i) => setState(() => _hour12 = _hours[i]),
                ),
              ),
              Expanded(
                child: _buildWheel(
                  controller: _minuteController,
                  itemCount: _minutes.length,
                  labelAt: (i) => _minutes[i].toString().padLeft(2, '0'),
                  isSelected: (i) => _minutes[i] == _minute,
                  onSelected: (i) => setState(() => _minute = _minutes[i]),
                ),
              ),
              Expanded(
                child: _buildWheel(
                  controller: _meridiemController,
                  itemCount: 2,
                  labelAt: (i) => i == 0 ? 'AM' : 'PM',
                  isSelected: (i) => (i == 1) == _isPm,
                  onSelected: (i) => setState(() => _isPm = i == 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int index) labelAt,
    required bool Function(int index) isSelected,
    required void Function(int index) onSelected,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: OvertimeTimePickerSheet._itemExtent,
      physics: const FixedExtentScrollPhysics(),
      diameterRatio: 2.2,
      perspective: 0.003,
      onSelectedItemChanged: onSelected,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final selected = isSelected(index);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            // La rueda se puede scrollear o tocar: al tocar, el valor viaja
            // hasta el centro y `onSelectedItemChanged` avisa al llegar.
            onTap: () => controller.animateToItem(
              index,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            ),
            child: Center(
              child: Text(
                labelAt(index),
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: selected ? 24 : 20,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: AppSpacing.ctaHeight,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: SizedBox(
            height: AppSpacing.ctaHeight,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _selectedMinutes),
              child: const Text(
                'Listo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
