import 'package:check_van_frontend/core/theme.dart';
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

  bool _isOptionInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR');

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
          .getMonthlyPresence(widget.studentId, _selectedDay);
    });
  }

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

  String? _mapStatusToOption(String? status) {
    switch (status) {
      case 'BOTH':
        return 'Ida e volta';
      case 'GOING':
        return 'Somente Ida';
      case 'RETURNING':
        return 'Somente Volta';
      case 'NONE':
        return 'Não utilizará o transporte';
      default:
        return null;
    }
  }

  Future<void> _confirmPresence() async {
    final presenceMap = context.read<PresenceProvider>().monthlyPresence;
    final isoDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final statusFromBackend = presenceMap[isoDate];
    final optionFromBackend = _mapStatusToOption(statusFromBackend);

    final optionToConfirm = _selectedTransportOption ?? optionFromBackend;

    if (optionToConfirm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma opção de transporte.'),
          backgroundColor: AppPalette.red700,
        ),
      );
      return;
    }

    final presenceProvider = Provider.of<PresenceProvider>(context, listen: false);
    final status = _mapOptionToStatus(optionToConfirm);

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
      //Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${presenceProvider.error ?? "Ocorreu um problema."}'),
          backgroundColor: AppPalette.red700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConfirming = context.watch<PresenceProvider>().isConfirming;
    final presenceMap = context.watch<PresenceProvider>().monthlyPresence;

    String? currentOptionToShow;

    final isoDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final statusFromBackend = presenceMap[isoDate];

    final optionFromBackend = _mapStatusToOption(statusFromBackend);

    currentOptionToShow = _selectedTransportOption ?? optionFromBackend;

    if (!_isOptionInitialized && presenceMap.isNotEmpty) {
      _selectedTransportOption = optionFromBackend;
      currentOptionToShow = optionFromBackend;
      _isOptionInitialized = true;
    }

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
            Text(
              _getFormattedDateString(_selectedDay),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),

            WeekSelector(
              initialSelectedDay: _selectedDay,
              onDaySelected: (newSelectedDay) {
                final newIsoDate = DateFormat('yyyy-MM-dd').format(newSelectedDay);
                final newStatus = presenceMap[newIsoDate];
                final newOption = _mapStatusToOption(newStatus);

                setState(() {
                  _selectedDay = newSelectedDay;
                  _selectedTransportOption = newOption;
                });
              },
              presenceStatusMap: presenceMap,
              onMonthChanged: (newDate) {
                Provider.of<PresenceProvider>(context, listen: false)
                    .getMonthlyPresence(widget.studentId, newDate);
              },
            ),
            const SizedBox(height: 24),

            PresenceOptions(
              selectedOption: currentOptionToShow,
              onChanged: (newOption) {
                setState(() {
                  _selectedTransportOption = newOption;
                });
              },
            ),
            const SizedBox(height: 24),

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