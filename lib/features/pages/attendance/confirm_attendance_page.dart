import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../core/theme.dart';
import '../../../provider/presence_provider.dart';
import '../../../provider/student_provider.dart';

class ConfirmAttendancePage extends StatefulWidget {
  final int studentId;
  final String studentName;
  final String? studentImageUrl;

  const ConfirmAttendancePage({
    Key? key,
    required this.studentId,
    required this.studentName,
    this.studentImageUrl,
  }) : super(key: key);

  @override
  State<ConfirmAttendancePage> createState() => _ConfirmAttendancePageState();
}

class _ConfirmAttendancePageState extends State<ConfirmAttendancePage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;
  String? _selectedTransportOption;
  final DateFormat _dateFormatter = DateFormat('EEEE, dd MMM yyyy', 'pt_BR');
  bool _isLoading = false;

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

  String _mapOptionToStatus(String? option) {
    switch (option) {
      case 'Ida e volta':
        return 'BOTH';
      case 'Somente Ida':
        return 'GOING';
      case 'Somente Volta':
        return 'RETURNING';
      case 'Não utilizará o transporte':
        return 'NONE';
      default:
        return '';
    }
  }

  Future<void> _confirmPresence() async {
    if (_selectedTransportOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma opção de transporte.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Acessa o provider sem ouvir mudanças, pois estamos apenas chamando um método
    final presenceProvider = Provider.of<PresenceProvider>(context, listen: false);
    final status = _mapOptionToStatus(_selectedTransportOption);

    final success = await presenceProvider.updatePresence(
      studentId: widget.studentId,
      date: _selectedDay,
      status: status,
    );

    // Garante que o widget ainda está na árvore antes de mostrar a SnackBar
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Presença confirmada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      // Atualiza o resumo de presença ao confirmar
      await context.read<StudentProvider>().getPresenceSummary();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${presenceProvider.error ?? "Ocorreu um problema."}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final presenceProvider = context.watch<PresenceProvider>();
    final isLoading = presenceProvider.isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        // TODO - aumentar o tamanho dessa appBar para deixar a imagem do aluno com raidus 40
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: (widget.studentImageUrl != null && widget.studentImageUrl!.isNotEmpty)
                      ? NetworkImage(widget.studentImageUrl!)
                      : const AssetImage('assets/profile.png') as ImageProvider,
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
                onPressed: isLoading ? null : _confirmPresence,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.green600,
                  foregroundColor: AppPalette.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                    : const Text(
                  'Confirmar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

