import 'package:check_van_frontend/features/widgets/route/active_route/route_etop_tile.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import 'package:check_van_frontend/model/student_model.dart';

class RouteStopList extends StatelessWidget {
  final ScrollController scrollController;
  final List<Student> students;
  final int currentStopIndex;
  final String schoolName;
  final String schoolEtaText;
  final String? nextStopEtaText;
  final Function(bool isSchool, String targetName) onForceArrival;

  const RouteStopList({
    super.key,
    required this.scrollController,
    required this.students,
    required this.currentStopIndex,
    required this.schoolName,
    required this.schoolEtaText,
    this.nextStopEtaText,
    required this.onForceArrival,
  });

  @override
  Widget build(BuildContext context) {
    final remainingStops = students.sublist(currentStopIndex);
    bool nextIsSchool = currentStopIndex == students.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              width: 40, height: 5,
              decoration: BoxDecoration(
                color: AppPalette.neutral300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Center(
            child: Text.rich(
              TextSpan(
                text: "Chegada na escola em: ",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.primary900,
                ),
                children: [
                  TextSpan(
                    text: schoolEtaText,
                    style: const TextStyle(color: AppPalette.primary800),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            nextIsSchool ? 'Destino Final' : 'Próximas paradas',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPalette.primary900),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: remainingStops.length + 1,
            itemBuilder: (context, index) {
              final bool isCurrentTarget = index == 0;

              // CASO ESCOLA
              if (index == remainingStops.length) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: RouteStopTile(
                    name: schoolName,
                    address: "Destino Final",
                    isLastStop: true,
                    isNextTarget: isCurrentTarget,
                    isSchool: true,
                    onTap: isCurrentTarget
                        ? () => onForceArrival(true, schoolName)
                        : null,
                  ),
                );
              }

              // CASO ALUNO
              final student = remainingStops[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: RouteStopTile(
                  name: student.name,
                  address: student.address ?? 'Endereço não informado',
                  isLastStop: false,
                  isNextTarget: isCurrentTarget,
                  imageUrl: student.image_profile,
                  etaBadge: isCurrentTarget ? nextStopEtaText : null,
                  onTap: isCurrentTarget
                      ? () => onForceArrival(false, student.name)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}