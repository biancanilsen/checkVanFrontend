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
    // Ligações locais não precisam de DDI obrigatório, mas ajuda
    // O esquema 'tel:' abre o discador
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanedPhone,
    );

    try {
      // Tenta lançar. Se canLaunch retornar false (por bug de OS), o catch pega.
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        // Tentativa forçada caso canLaunch minta (comum em algumas ROMs)
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
    // WhatsApp exige DDI. Se não tiver, adiciona 55 (Brasil)
    if (cleanedPhone.length <= 11) {
      cleanedPhone = '55$cleanedPhone';
    }

    // URL oficial do WhatsApp
    final Uri launchUri = Uri.parse('https://wa.me/$cleanedPhone');

    try {
      // LaunchMode.externalApplication é CRUCIAL para abrir o App do WhatsApp
      // e não um navegador dentro do seu app.
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