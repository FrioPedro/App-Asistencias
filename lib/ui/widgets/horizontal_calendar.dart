import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importante para inicializar locales

class HorizontalCalendar extends StatefulWidget {
  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthChanged;

  const HorizontalCalendar({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  State<HorizontalCalendar> createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalCalendar> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null).then((_) {
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si no ha cargado el locale, mostramos un loader o el calendario en inglés/defecto
    // Para UX rápida, podemos intentar mostrarlo, pero si falla DateFormat('es_ES') explotaría.
    // Así que esperamos _initialized.
    if (!_initialized) {
      return const SizedBox(
        height: 120, // Altura aproximada del widget
        child: Center(child: SizedBox.shrink()), // O un loader muy sutil
      );
    }

    final daysInMonth = _getDaysInMonth(widget.focusedMonth);
    // Ahora es seguro usar es_ES
    final monthName = DateFormat('MMMM yyyy', 'es_ES')
        .format(widget.focusedMonth)
        .toUpperCase();

    return Column(
      children: [
        // --- MONTH HEADER ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {
                  final newMonth = DateTime(
                      widget.focusedMonth.year, widget.focusedMonth.month - 1);
                  widget.onMonthChanged(newMonth);
                },
              ),
              Text(
                monthName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () {
                  final newMonth = DateTime(
                      widget.focusedMonth.year, widget.focusedMonth.month + 1);
                  widget.onMonthChanged(newMonth);
                },
              ),
            ],
          ),
        ),

        // --- DAYS STRIP ---
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: daysInMonth.length,
            itemBuilder: (context, index) {
              final date = daysInMonth[index];
              final isSelected = widget.selectedDate != null &&
                  date.year == widget.selectedDate!.year &&
                  date.month == widget.selectedDate!.month &&
                  date.day == widget.selectedDate!.day;

              return GestureDetector(
                onTap: () => widget.onDateSelected(date),
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2E60C4)
                        : const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.blueAccent, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E', 'es_ES')
                            .format(date)
                            .toUpperCase(), // LUN/MAR
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final days = <DateTime>[];
    final daysCount = DateUtils.getDaysInMonth(month.year, month.month);
    for (var i = 0; i < daysCount; i++) {
      days.add(first.add(Duration(days: i)));
    }
    return days;
  }
}
