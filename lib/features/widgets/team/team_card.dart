import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

class TeamCard extends StatelessWidget {
  final String name;
  final String period;
  final int studentCount;
  final String code;

  const TeamCard({
    super.key,
    required this.name,
    required this.period,
    required this.studentCount,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.neutral70,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha Superior: Título e Ícone de Edição
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.primary900,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: AppPalette.primary800, size: 20),
                  onPressed: () { /* Ação de editar turma */ },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            // Linha do Meio: Informações
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coluna da Esquerda
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Período: $period',
                        style: TextStyle(color: AppPalette.primary900, fontWeight: FontWeight.w400, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Alunos',
                        style: TextStyle(color: AppPalette.primary900, fontWeight: FontWeight.w400, fontSize: 14),
                      ),
                      Text(
                        '$studentCount',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.primary900,
                        ),
                      ),
                    ],
                  ),
                ),
                // Coluna da Direita
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Espaço vazio para alinhar "Código" com "Alunos"
                      const SizedBox(height: 30),
                      Text(
                        'Código',
                        style: TextStyle(color: AppPalette.primary900, fontWeight: FontWeight.w400, fontSize: 14),
                      ),
                      Text(
                        code,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppPalette.primary900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botão Inferior
            OutlinedButton(
              onPressed: () { /* Ação "Ver turma" */ },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                foregroundColor: AppPalette.primary800,
                side: BorderSide(color: AppPalette.primary800),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Ver turma', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}