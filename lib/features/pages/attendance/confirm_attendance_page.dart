import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../provider/presence_provider.dart';
import '../../../provider/student_provider.dart';

import '../../widgets/attendance/attendance_app_bar.dart';
import '../../widgets/attendance/confirm_button.dart';
import '../../widgets/attendance/presence_options.dart';
import '../../widgets/attendance/week_selector.dart';

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
  String? _selectedTransportOption;
  final DateFormat _dateFormatter = DateFormat('EEEE, dd MMM yyyy', 'pt_BR');

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR');

    // Lógica para pular fins de semana (permanece no controlador)
    DateTime now = DateTime.now();
    if (now.weekday == DateTime.saturday) {
      _selectedDay = now.add(const Duration(days: 2));
    } else if (now.weekday == DateTime.sunday) {
      _selectedDay = now.add(const Duration(days: 1));
    } else {
      _selectedDay = now;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PresenceProvider>(context, listen: false)
          .getMonthlyPresence(widget.studentId, _selectedDay); // Passa a data
    });
  }

  /// Formata a string de data (permanece no controlador)
  String _getFormattedDateString(DateTime date) {
    String formattedDate = _dateFormatter.format(date);
    String cleanedDate = formattedDate.replaceAll('-feira', '');
    List<String> parts = cleanedDate.split(' ');

    if (parts.isNotEmpty) {
      parts[0] = '${parts[0][0].toUpperCase()}${parts[0].substring(1)}';
    }
    if (parts.length > 2) {
      parts[2] = '${parts[2][0].toUpperCase()}${parts[2].substring(1)}';
    }
    return parts.join(' ');
  }

  /// Mapeia opção para status (lógica de negócio, permanece no controlador)
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

  /// Confirma presença (lógica de negócio, permanece no controlador)
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

    final presenceProvider = Provider.of<PresenceProvider>(context, listen: false);
    final status = _mapOptionToStatus(_selectedTransportOption);

    final success = await presenceProvider.updatePresence(
      studentId: widget.studentId,
      date: _selectedDay,
      status: status,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Presença confirmada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
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
    final isConfirming = context.watch<PresenceProvider>().isConfirming;
    final presenceMap = context.watch<PresenceProvider>().monthlyPresence;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AttendanceAppBar(
        studentName: widget.studentName,
        studentImageUrl: widget.studentImageUrl,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            // Texto da data selecionada
            Text(
              _getFormattedDateString(_selectedDay),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),

            // Componente 1: Seletor de Semana
            WeekSelector(
              initialSelectedDay: _selectedDay,
              onDaySelected: (newSelectedDay) {
                setState(() {
                  _selectedDay = newSelectedDay;
                });
              },
              // ATUALIZADO: Passa o mapa de presença
              presenceStatusMap: presenceMap,
              // ADICIONADO: O callback para buscar novos meses
              onMonthChanged: (newDate) {
                Provider.of<PresenceProvider>(context, listen: false)
                    .getMonthlyPresence(widget.studentId, newDate);
              },
            ),
            const SizedBox(height: 24),

            // Componente 2: Opções de Presença
            PresenceOptions(
              selectedOption: _selectedTransportOption,
              onChanged: (newOption) {
                setState(() {
                  _selectedTransportOption = newOption;
                });
              },
            ),
            const SizedBox(height: 24),

            // Componente 3: Botão de Confirmação
            ConfirmButton(
              isLoading: isConfirming,
              onPressed: _confirmPresence,
            ),
          ],
        ),
      ),
    );
  }
}