import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'week_selector_day_card.dart';

class WeekSelector extends StatefulWidget {
  final DateTime initialSelectedDay;
  final Function(DateTime) onDaySelected;
  final Map<String, String?> presenceStatusMap;
  final Function(DateTime newDate)? onMonthChanged;

  const WeekSelector({
    super.key,
    required this.initialSelectedDay,
    required this.onDaySelected,
    required this.presenceStatusMap,
    this.onMonthChanged,
  });

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
              final isSelected = isSameDay(day, _selectedDay);

              return WeekSelectorDayCard(
                day: day,
                isSelected: isSelected,
                status: status,
                onTap: () => _onDayCardSelected(day),
              );
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
}