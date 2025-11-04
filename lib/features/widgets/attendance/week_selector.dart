import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';

class WeekSelector extends StatefulWidget {
  final DateTime initialSelectedDay;
  final Function(DateTime) onDaySelected;
  final Map<String, String?> presenceStatusMap;

  const WeekSelector({
    Key? key,
    required this.initialSelectedDay,
    required this.onDaySelected,
    required this.presenceStatusMap,
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
    // Notifica o widget pai sobre a mudança
    widget.onDaySelected(selectedDay);
  }

  void _goToPreviousWeek() {
    setState(() {
      _focusedDay = _focusedDay.subtract(const Duration(days: 7));
      _updateCurrentWeek(_focusedDay);
    });
  }

  void _goToNextWeek() {
    setState(() {
      _focusedDay = _focusedDay.add(const Duration(days: 7));
      _updateCurrentWeek(_focusedDay);
    });
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
                // ADICIONAR LÓGICA:
                // 1. Formata a data do card para "YYYY-MM-DD" para ser a chave do mapa
                final isoDate = DateFormat('yyyy-MM-dd').format(day);

                // 2. Busca o status no mapa
                final status = widget.presenceStatusMap[isoDate]; // Ex: "GOING", "NONE", ou null

                // 3. Passa o status para o _buildDayCard
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

    // ADICIONAR LÓGICA DO ÍCONE:
    IconData iconData;
    Color iconColor;

    // if (isSelected) {
    //   // Se está selecionado, o ícone é sempre o check verde (feedback de seleção)
    //   //iconData = Icons.check_circle;
    //   //iconColor = AppPalette.green600;
    // }
      // Se não está selecionado, usa a lógica de status
      switch (status) {
        case 'BOTH':
        case 'GOING':
        case 'RETURNING':
          iconData = Icons.check_circle_outline; // Ícone de check (pode ser o preenchido também)
          iconColor = AppPalette.green600; // Verde
          break;
        case 'NONE':
          iconData = Icons.cancel_outlined; // Ícone X (ou Icons.close)
          iconColor = Colors.red.shade700; // Vermelho
          break;
        case null: // "Não tem registro" (veio null do backend)
        default:
          iconData = Icons.watch_later_outlined;
          iconColor = Colors.orange.shade700; // Laranja

    }

    return GestureDetector(
      onTap: () => _onDayCardSelected(day),
      child: Container(
        // Reduzi o padding como na sua pergunta anterior
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
            // USAR O ÍCONE DINÂMICO
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