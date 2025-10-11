import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../core/theme.dart';

class ConfirmarPresencaPage extends StatefulWidget {
  final int studentId;
  final String studentName;
  final String studentImageUrl;

  const ConfirmarPresencaPage({
    Key? key,
    required this.studentId,
    required this.studentName,
    required this.studentImageUrl,
  }) : super(key: key);

  @override
  State<ConfirmarPresencaPage> createState() => _ConfirmarPresencaPageState();
}

class _ConfirmarPresencaPageState extends State<ConfirmarPresencaPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;
  String? _selectedTransportOption;
  // CORREÇÃO: Removido o ponto explícito de 'MMM.' para 'MMM'
  final DateFormat _dateFormatter = DateFormat('EEEE, dd MMM yyyy', 'pt_BR');

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR');
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  /// Formata a string de data para capitalizar e remover o "-feira".
  String _getFormattedDateString(DateTime date) {
    String formattedDate = _dateFormatter.format(date);
    // Ex: "segunda-feira, 08 out. 2025"

    // Remove o "-feira" da string
    String cleanedDate = formattedDate.replaceAll('-feira', '');

    List<String> parts = cleanedDate.split(' ');

    // Capitaliza o dia da semana (primeira parte)
    if (parts.isNotEmpty) {
      String dayOfWeek = parts[0];
      parts[0] = '${dayOfWeek[0].toUpperCase()}${dayOfWeek.substring(1)}';
    }

    // Capitaliza o mês (terceira parte)
    if (parts.length > 2) {
      String month = parts[2];
      // A abreviação já vem com ponto, então apenas capitalizamos
      if (month.isNotEmpty) {
        parts[2] = '${month[0].toUpperCase()}${month.substring(1)}';
      }
    }

    return parts.join(' ');
  }

  Future<void> _confirmPresence() async {
    // ... (seu método _confirmPresence)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true, // Centraliza o título
        title: Row(
          mainAxisSize: MainAxisSize.min, // Para o Row não ocupar todo o espaço
          children: [
            CircleAvatar(
              radius: 20, // Raio menor para a AppBar
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: Image.asset(
                  widget.studentImageUrl, // Use a imagem recebida
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.studentName, // Use o nome recebido
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  locale: 'pt_BR',
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: _onDaySelected,
                  headerVisible: true,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextFormatter: (date, locale) {
                      String formatted = DateFormat.yMMMM(locale).format(date);
                      return '${formatted[0].toUpperCase()}${formatted.substring(1)}';
                    },
                  ),
                  // Builder para customizar os dias da semana
                  calendarBuilders: CalendarBuilders(
                    dowBuilder: (context, day) {
                      final text = DateFormat.E('pt_BR').format(day);
                      final dayName = text.replaceAll('.', '');
                      return Center(
                        child: Text(
                          '${dayName[0].toUpperCase()}${dayName.substring(1)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 32),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                      _selectedDay = _focusedDay;
                    });
                  },
                ),
                Text(
                  _getFormattedDateString(_selectedDay),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 32),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                      _selectedDay = _focusedDay;
                    });
                  },
                ),
              ],
            ),
            ...['Ida e volta', 'Somente Ida', 'Somente Volta', 'Não utilizará o transporte']
                .map(
                  (option) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedTransportOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedTransportOption = value;
                      });
                    },
                    activeColor: Colors.black87,
                  ),
                ),
              ),
            )
                .toList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _confirmPresence,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.green600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

