import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NoStudentCallout extends StatelessWidget {
  const NoStudentCallout({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Column(
        children: [
          Image.asset(
            'assets/rota.png',
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            color: AppPalette.green75,
            child: Center(
              child: Text(
                'Sem alunos para monitorar, começe criando um pelo menu abaixo',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppPalette.primary900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}