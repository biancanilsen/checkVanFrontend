import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';

class WeekSelector extends StatefulWidget {
  final DateTime initialSelectedDay;
  final Function(DateTime) onDaySelected;
  final Map<String, String?> presenceStatusMap;

  final Function(DateTime newDate)? onMonthChanged;

  const WeekSelector({
    Key? key,
    required this.initialSelectedDay,
    required this.onDaySelected,
    required this.presenceStatusMap,
    this.onMonthChanged,
  }) : super(key: key);

  @override
  State<WeekSelector> createState() => _WeekSelectorState();
}

class _WeekSelectorState extends State<WeekSelector> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  List<DateTime> _currentWeekDays = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialSelectedDay;
    _focusedDay = widget.initialSelectedDay;
    _updateCurrentWeek(_focusedDay);
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _updateCurrentWeek(DateTime anchorDay) {
    DateTime startOfWeek = anchorDay.subtract(Duration(days: anchorDay.weekday - 1));
    setState(() {
      _currentWeekDays = List.generate(5, (index) => startOfWeek.add(Duration(days: index)));
    });
  }

  void _onDayCardSelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay;
    });
    widget.onDaySelected(selectedDay);
  }

  void _goToPreviousWeek() {
    final int oldMonth = _focusedDay.month;

    setState(() {
      _focusedDay = _focusedDay.subtract(const Duration(days: 7));
      _updateCurrentWeek(_focusedDay);
    });

    if (_focusedDay.month != oldMonth && widget.onMonthChanged != null) {
      widget.onMonthChanged!(_focusedDay);
    }
  }

  void _goToNextWeek() {
    final int oldMonth = _focusedDay.month;

    setState(() {
      _focusedDay = _focusedDay.add(const Duration(days: 7));
      _updateCurrentWeek(_focusedDay);
    });

    if (_focusedDay.month != oldMonth && widget.onMonthChanged != null) {
      widget.onMonthChanged!(_focusedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 30, color: Colors.black54),
          onPressed: _goToPreviousWeek,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _currentWeekDays.map((day) {
              final isoDate = DateFormat('yyyy-MM-dd').format(day);
              final status = widget.presenceStatusMap[isoDate];

              return _buildDayCard(day, status);
            }).toList(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 30, color: Colors.black54),
          onPressed: _goToNextWeek,
        ),
      ],
    );
  }

  Widget _buildDayCard(DateTime day, String? status) {
    final isSelected = isSameDay(day, _selectedDay);
    final dayFormat = DateFormat.E('pt_BR').format(day);
    final dayAbbreviation =
        '${dayFormat[0].toUpperCase()}${dayFormat.substring(1)}';
    final dayNumber = DateFormat.d('pt_BR').format(day);

    IconData iconData;
    Color iconColor;

    switch (status) {
      case 'BOTH':
      case 'GOING':
      case 'RETURNING':
        iconData = Icons.check_circle_outline;
        iconColor = AppPalette.green600;
        break;
      case 'NONE':
        iconData = Icons.cancel_outlined;
        iconColor = AppPalette.red700;
        break;
      case null:
      default:
        iconData = Icons.watch_later_outlined;
        iconColor = AppPalette.orange700;
    }

    return GestureDetector(
      onTap: () => _onDayCardSelected(day),
      child: Container(
        // Padding reduzido para evitar overflow
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppPalette.green600, width: 2)
              : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          children: [
            Text(
              dayAbbreviation,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppPalette.green600 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNumber,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppPalette.green600 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              iconData,
              color: iconColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}