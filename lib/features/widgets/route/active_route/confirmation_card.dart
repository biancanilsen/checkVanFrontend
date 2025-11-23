import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import 'package:check_van_frontend/model/student_model.dart';

class ConfirmationCard extends StatelessWidget {
  final Student? student;
  final String schoolName;
  final bool isBoarding;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final VoidCallback? onMarkAbsent;

  const ConfirmationCard({
    super.key,
    required this.student,
    required this.schoolName,
    required this.isBoarding,
    required this.onCancel,
    required this.onConfirm,
    this.onMarkAbsent,
  });

  @override
  Widget build(BuildContext context) {
    final isSchool = student == null;
    final String displayName = isSchool ? schoolName : student!.name;
    final String displayAddress = isSchool ? "Destino Final" : (student!.address ?? 'Endereço não informado');
    final String? displayImage = isSchool ? null : student!.image_profile;
    final Color primaryButtonColor = isSchool ? AppPalette.primary800 : AppPalette.green500;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 5,
              decoration: BoxDecoration(
                color: AppPalette.neutral300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppPalette.primary900),
                onPressed: onCancel,
                tooltip: 'Voltar para lista',
              ),
              Expanded(
                child: Text(
                  isSchool ? 'Chegamos na Escola' : 'Confirmar embarque',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPalette.primary900),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isSchool ? AppPalette.primary800 : AppPalette.neutral150,
                backgroundImage: (displayImage != null && displayImage.isNotEmpty)
                    ? NetworkImage(displayImage)
                    : null,
                child: (displayImage == null || isSchool)
                    ? Icon(isSchool ? Icons.school : Icons.person, color: Colors.white, size: 30)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(displayAddress, style: const TextStyle(color: AppPalette.neutral600)),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          if (isSchool)
            ElevatedButton(
              onPressed: isBoarding ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryButtonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              child: isBoarding
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                  : const Text('Finalizar Rota'),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isBoarding ? null : onMarkAbsent,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.red700,
                      side: const BorderSide(color: AppPalette.red700),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Ausente'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isBoarding ? null : onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    child: isBoarding
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                        : const Text('Embarcar'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}