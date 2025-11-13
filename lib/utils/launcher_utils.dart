import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:check_van_frontend/core/theme.dart'; // Importe seu AppPalette

class LauncherUtils {
  // Helper interno para limpar o número (remove '(', ')', '-', ' ')
  static String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[\s()-]'), '');
  }

  // Helper interno para mostrar erros
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppPalette.red500,
      ),
    );
  }

  /// Tenta fazer uma ligação telefônica
  static Future<void> makePhoneCall(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showError(context, 'Número de telefone não cadastrado.');
      return;
    }

    // Limpa o número e assume DDI +55 (Brasil) se não estiver presente
    String cleanedPhone = _cleanPhoneNumber(phoneNumber);
    if (!cleanedPhone.startsWith('+')) {
      cleanedPhone = '+55$cleanedPhone';
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanedPhone,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showError(context, 'Não foi possível fazer a ligação.');
    }
  }

  /// Tenta abrir o WhatsApp
  static Future<void> openWhatsApp(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showError(context, 'Número de telefone não cadastrado.');
      return;
    }

    // Limpa o número e assume DDI 55 (sem o +)
    String cleanedPhone = _cleanPhoneNumber(phoneNumber);
    if (cleanedPhone.length <= 11) { // Verifica se é um número local (sem DDI)
      cleanedPhone = '55$cleanedPhone';
    }

    final Uri launchUri = Uri.parse('https://wa.me/$cleanedPhone');

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      _showError(context, 'Não foi possível abrir o WhatsApp.');
    }
  }
}