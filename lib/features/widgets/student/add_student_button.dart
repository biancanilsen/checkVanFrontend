import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../provider/student_provider.dart';
import '../../pages/student/add_student_page.dart';

class AddStudentButton extends StatelessWidget {
  const AddStudentButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Adicionar aluno',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/add-student');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPalette.green600,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }
}