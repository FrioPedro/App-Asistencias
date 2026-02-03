import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/log_model.dart';
import '../../widgets/calendar_modal.dart';

class LogFilterSheet extends StatefulWidget {
  final DateTimeRange? initialDateRange;
  final List<LogType> initialTypes;
  final Function(DateTimeRange?, List<LogType>) onApply;

  const LogFilterSheet({
    super.key,
    this.initialDateRange,
    required this.initialTypes,
    required this.onApply,
  });

  @override
  State<LogFilterSheet> createState() => _LogFilterSheetState();
}

class _LogFilterSheetState extends State<LogFilterSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  late List<LogType> _selectedTypes;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDateRange?.start;
    _endDate = widget.initialDateRange?.end;
    _selectedTypes = List.from(widget.initialTypes);
  }

  void _toggleType(LogType type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _openDatePicker(bool isStart) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => CalendarModal(
        initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
        onDateSelected: (date) {
          setState(() {
            if (isStart) {
              _startDate = date;
              if (_endDate != null && _endDate!.isBefore(_startDate!)) {
                _endDate = null;
              }
            } else {
              _endDate = date;
              if (_startDate != null && _startDate!.isAfter(_endDate!)) {
                _startDate = null;
              }
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtrar Logs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // TIPO DE LOG
          const Text(
            'Tipo de Log',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: LogType.values.map((type) {
              final isSelected = _selectedTypes.contains(type);
              Color typeColor;
              String label;
              switch (type) {
                case LogType.error:
                  typeColor = const Color(0xFFEF5350);
                  label = 'ERR';
                  break;
                case LogType.warning:
                  typeColor = const Color(0xFFFFCA28);
                  label = 'ADV';
                  break;
                case LogType.info:
                  typeColor = const Color(0xFF42A5F5);
                  label = 'INF';
                  break;
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => _toggleType(type),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? typeColor.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? typeColor : Colors.grey[800]!,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? typeColor : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // FECHAS
          const Text(
            'Rango de Fecha',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                    'Desde', _startDate, () => _openDatePicker(true)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateSelector(
                    'Hasta', _endDate, () => _openDatePicker(false)),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // BOTONES
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                      _selectedTypes = [];
                    });
                  },
                  child: const Text('Limpiar Todo',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    DateTimeRange? range;
                    if (_startDate != null && _endDate != null) {
                      range = DateTimeRange(start: _startDate!, end: _endDate!);
                    } else if (_startDate != null || _endDate != null) {
                      final date = _startDate ?? _endDate!;
                      range = DateTimeRange(start: date, end: date);
                    }
                    widget.onApply(range, _selectedTypes);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E60C4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('APLICAR',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  date != null ? const Color(0xFF2E60C4) : Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  _formatDate(date),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
