import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:check_van_frontend/core/theme.dart';

class LauncherUtils {
  static String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[\s()-]'), '');
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppPalette.red500,
      ),
    );
  }

  static Future<void> makePhoneCall(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showError(context, 'Número de telefone não cadastrado.');
      return;
    }

    String cleanedPhone = _cleanPhoneNumber(phoneNumber);
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanedPhone,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(launchUri);
      }
    } catch (e) {
      _showError(context, 'Não foi possível fazer a ligação.');
    }
  }

  static Future<void> openWhatsApp(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showError(context, 'Número de telefone não cadastrado.');
      return;
    }

    String cleanedPhone = _cleanPhoneNumber(phoneNumber);
    if (cleanedPhone.length <= 11) {
      cleanedPhone = '55$cleanedPhone';
    }

    final Uri launchUri = Uri.parse('https://wa.me/$cleanedPhone');

    try {
      bool launched = await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showError(context, 'WhatsApp não instalado ou erro ao abrir.');
      }
    } catch (e) {
      _showError(context, 'Erro ao abrir WhatsApp.');
    }
  }
}