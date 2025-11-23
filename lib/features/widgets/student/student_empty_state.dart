import 'package:flutter/material.dart';

class StudentEmptyState extends StatelessWidget {
  const StudentEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          //Icon(Icons.person_off_outlined, size: 48, color: Colors.grey[400]),
          //const SizedBox(height: 16),
          const Text(
            'Nenhum aluno encontrado.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}