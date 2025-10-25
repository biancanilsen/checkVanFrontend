import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../model/student_model.dart';
import 'student_list_item.dart';
import 'package:check_van_frontend/core/theme.dart';

class StudentAccordion extends StatefulWidget {
  final String title;
  final int count;
  final Color countColor;
  final List<Student> students;
  final IconData? itemIcon;
  final Color? itemIconColor;
  final bool initiallyExpanded;

  const StudentAccordion({
    super.key,
    required this.title,
    required this.count,
    required this.countColor,
    required this.students,
    this.itemIcon,
    this.itemIconColor,
    this.initiallyExpanded = false,
  });

  @override
  State<StudentAccordion> createState() => _StudentAccordionState();
}

class _StudentAccordionState extends State<StudentAccordion> {
  late bool _isExpanded;
  bool _isEmpty = false;

  @override
  void initState() {
    super.initState();
    _isEmpty = widget.students.isEmpty;
    _isExpanded = widget.initiallyExpanded && !_isEmpty;
  }

  void _toggleExpanded() {
    if (_isEmpty) return;

    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    String displayTitle = widget.title;
    // Se a contagem for 0 ou 1 E o título terminar com 's', remove o 's'
    if (widget.count <= 1 && widget.title.endsWith('s')) {
      displayTitle = widget.title.substring(0, widget.title.length - 1);
    }
    final cardColor = (_isExpanded && !_isEmpty)
        ? AppPalette.white
        : AppPalette.appBackground;

    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: cardColor, // Cor de fundo atualizada
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: _isEmpty ? null : _toggleExpanded,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                children: [
                  Text(
                    widget.count.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.countColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    displayTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.neutral800,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded && !_isEmpty
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _isEmpty
                        ? AppPalette.neutral200
                        : AppPalette.neutral600,
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded && !_isEmpty)
            Column(
              children: [
                // Divisor
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
                // Lista de Alunos
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.students.length,
                  itemBuilder: (context, index) {
                    final student = widget.students[index];
                    return StudentListItem(
                      index: index + 1,
                      name: student.name,
                      address: student.address,
                      trailIcon: widget.itemIcon,
                      trailIconColor: widget.itemIconColor,
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
        ],
      ),
    );
  }
}