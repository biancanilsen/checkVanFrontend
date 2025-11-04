import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  late DateTime _focusedDay; // Usado como âncora para a semana
  List<DateTime> _currentWeekDays = [];
  String? _selectedTransportOption;
  final DateFormat _dateFormatter = DateFormat('EEEE, dd MMM yyyy', 'pt_BR');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR');

    DateTime now = DateTime.now();
    _focusedDay = now;

    // [MODIFICADO] Lógica para pular fins de semana
    // Se for Sábado (6), avança para Segunda (adiciona 2 dias)
    if (now.weekday == DateTime.saturday) {
      _selectedDay = now.add(const Duration(days: 2));
    }
    // Se for Domingo (7), avança para Segunda (adiciona 1 dia)
    else if (now.weekday == DateTime.sunday) {
      _selectedDay = now.add(const Duration(days: 1));
    }
    // Se for um dia de semana, é o dia selecionado
    else {
      _selectedDay = now;
    }

    // O _focusedDay também deve ser atualizado para a nova data selecionada
    // para que a semana correta seja exibida
    _focusedDay = _selectedDay;

    _updateCurrentWeek(_focusedDay);
  }

  /// Adiciona um helper local já que TableCalendar foi removido
  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// [MODIFICADO] Calcula os 5 dias da semana (Seg-Sex) com base em um dia âncora
  void _updateCurrentWeek(DateTime anchorDay) {
    // 1 = Segunda, 7 = Domingo.
    // Subtrai os dias para encontrar a Segunda-feira
    DateTime startOfWeek = anchorDay.subtract(Duration(days: anchorDay.weekday - 1));
    setState(() {
      // Alterado de 7 para 5 dias (Seg-Sex)
      _currentWeekDays = List.generate(5, (index) => startOfWeek.add(Duration(days: index)));
    });
  }

  void _onDayCardSelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay; // Foca no dia selecionado
    });
  }

  void _goToPreviousWeek() {
    setState(() {
      // Pula 7 dias para cair na mesma semana (Seg-Sex)
      _focusedDay = _focusedDay.subtract(const Duration(days: 7));
      _updateCurrentWeek(_focusedDay);
    });
  }

  void _goToNextWeek() {
    setState(() {
      // Pula 7 dias para cair na mesma semana (Seg-Sex)
      _focusedDay = _focusedDay.add(const Duration(days: 7));
      _updateCurrentWeek(_focusedDay);
    });
  }

  /// Formata a string de data para capitalizar e remover o "-feira".
  String _getFormattedDateString(DateTime date) {
    String formattedDate = _dateFormatter.format(date);
    String cleanedDate = formattedDate.replaceAll('-feira', '');
    List<String> parts = cleanedDate.split(' ');

    if (parts.isNotEmpty) {
      String dayOfWeek = parts[0];
      parts[0] = '${dayOfWeek[0].toUpperCase()}${dayOfWeek.substring(1)}';
    }
    if (parts.length > 2) {
      String month = parts[2];
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
    final presenceProvider = context.watch<PresenceProvider>();
    _isLoading = presenceProvider.isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 40),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.all(0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  child: ClipOval(
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: (widget.studentImageUrl != null && widget.studentImageUrl!.isNotEmpty)
                          ? NetworkImage(widget.studentImageUrl!)
                          : const AssetImage('assets/profile.png') as ImageProvider,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.studentName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            // Texto da data selecionada
            Text(
              _getFormattedDateString(_selectedDay),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppPalette.neutral900,
              ),
            ),
            const SizedBox(height: 16),

            // Novo Seletor de Semana
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botão de semana anterior
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 30, color: Colors.black54),
                  onPressed: _goToPreviousWeek,
                ),

                // Container para os dias da semana (agora com 5 dias)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _currentWeekDays.map((day) {
                      return Flexible(
                        child: _buildDayCard(day),
                      );
                    }).toList(),
                  ),
                ),

                // Botão de próxima semana
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 30, color: Colors.black54),
                  onPressed: _goToNextWeek,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Opções de Rádio
            ...['Ida e volta', 'Somente Ida', 'Somente Volta', 'Não utilizará o transporte']
                .map(
                  (option) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  elevation: 0, // Remove a sombra
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    // Adiciona a borda cinza clara
                    side: BorderSide(color: Colors.grey.shade300, width: 1.0),
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
                    activeColor: AppPalette.neutral700,
                    fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return AppPalette.neutral700;
                      }
                      return AppPalette.neutral500;
                    }),
                  ),
                ),
              ),
            )
                .toList(),
            const SizedBox(height: 24),

            // Botão Confirmar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmPresence,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.green600,
                  foregroundColor: AppPalette.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
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

  /// Widget para construir cada card de dia no seletor de semana
  Widget _buildDayCard(DateTime day) {
    final isSelected = isSameDay(day, _selectedDay);
    final dayFormat = DateFormat.E('pt_BR').format(day);
    final dayAbbreviation = '${dayFormat[0].toUpperCase()}${dayFormat.substring(1)}'.replaceAll('.', '');
    final dayNumber = DateFormat.d('pt_BR').format(day);

    return GestureDetector(
      onTap: () => _onDayCardSelected(day),
      child: Container(
        // Ajuste o tamanho/padding conforme necessário para caber 5 na tela
        width: 50, // Aumentei um pouco a largura para preencher melhor
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppPalette.green600, width: 2)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              dayAbbreviation,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppPalette.green600 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNumber,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppPalette.green600 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              isSelected ? Icons.check_circle : Icons.watch_later_outlined,
              color: isSelected ? AppPalette.green600 : Colors.orange.shade700,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}