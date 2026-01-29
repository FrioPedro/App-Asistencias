import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarModal extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const CalendarModal({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarModal> createState() => _CalendarModalState();
}

class _CalendarModalState extends State<CalendarModal> {
  late DateTime _focusedMonth;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _focusedMonth = widget.initialDate;
    initializeDateFormatting('es_ES', null).then((_) {
      if (mounted) {
        setState(() => _initialized = true);
      }
    });
  }

  void _changeMonth(int increment) {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + increment);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SizedBox(
        height: 350,
        child:
            Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
      );
    }

    final monthName =
        DateFormat('MMMM yyyy', 'es_ES').format(_focusedMonth).toUpperCase();
    final days = _getDaysInMonth(_focusedMonth);

    // Nombres de días de la semana
    final weekDays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Sidebar del tamaño del contenido
        children: [
          // Header: Mes y Flechas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => _changeMonth(-1),
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
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Días de la semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map((d) => SizedBox(
                      width: 40,
                      child: Center(
                          child: Text(d,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold))),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Grid de Días
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length + _getFirstDayOffset(days.first),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final offset = _getFirstDayOffset(days.first);
              if (index < offset) return const SizedBox();

              final date = days[index - offset];
              final isSelected = _isSameDay(date, widget.initialDate);
              final isToday = _isSameDay(date, DateTime.now());

              return GestureDetector(
                onTap: () {
                  widget.onDateSelected(date);
                  Navigator.pop(
                      context); // Cerrar automáticamente al seleccionar
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4CAF50)
                        : (isToday
                            ? const Color(0xFF4CAF50).withOpacity(0.2)
                            : Colors.transparent),
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: const Color(0xFF4CAF50))
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  int _getFirstDayOffset(DateTime firstDayOfMonth) {
    // DateTime.weekday devuelve 1 (Mon) a 7 (Sun)
    // Queremos que Lunes sea 0 offset.
    return firstDayOfMonth.weekday - 1;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysCount = DateUtils.getDaysInMonth(month.year, month.month);
    return List.generate(
        daysCount, (index) => first.add(Duration(days: index)));
  }
}
