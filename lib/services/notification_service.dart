import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart'; // Importe o Material
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:check_van_frontend/utils/user_session.dart';
import 'package:check_van_frontend/network/endpoints.dart';

import 'navigation_service.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Recebida notificação em background: ${message.messageId}");
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static const String _channelId = 'checkvan_channel_id';


  static Future<void> initListeners() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configuração para ícone de notificação (Android)
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/notification_icon');

    // Configuração do iOS
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    // Cria o canal de notificação (para o Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      'Lembretes CheckVan',
      description: 'Canal para lembretes de presença e rotas',
      importance: Importance.max,
    );

    // Registra o canal no sistema Android
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);


    // --- Lidar com app ABERTO A PARTIR DO ESTADO "FECHADO" ---
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('App aberto a partir de notificação (TERMINADO): ${initialMessage.messageId}');
      // Damos um pequeno atraso para a UI do Flutter carregar antes de navegar
      Future.delayed(const Duration(seconds: 1), () {
        _navigateToHome();
      });
    }
    // --- FIM DA ADIÇÃO ---

    // Configura os "ouvintes" para app aberto/background
    _setupListeners();
  }

  // Método público para ser chamado APÓS o login.
  static Future<void> registerToken() async {
    try {
      // 1. Obter o Token FCM
      final String? fcmToken = await _firebaseMessaging.getToken();

      // 2. Salvar o Token no Backend
      if (fcmToken != null) {
        print("===================================");
        print("FCM Token: $fcmToken");
        print("===================================");
        await _saveTokenToBackend(fcmToken);
      }
    } catch (e) {
      print("Erro ao obter e registrar FCM Token: $e");
    }
  }

  // Método privado para salvar o token
  static Future<void> _saveTokenToBackend(String token) async {
    try {
      final authToken = await UserSession.getToken();
      if (authToken == null) {
        print('Token de auth não encontrado, não é possível salvar Fcm Token.');
        return;
      }

      final url = Uri.parse('${Endpoints.baseUrl}/user/save-fcm-token');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'fcm_token': token}),
      );

      if (response.statusCode == 200) {
        print('FCM Token salvo no backend com sucesso.');
      } else {
        print('Falha ao salvar Fcm Token: ${response.body}');
      }
    } catch (e) {
      print('Erro ao tentar salvar Fcm Token: $e');
    }
  }


  static void _setupListeners() {
    // A. App ABERTO (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Recebida notificação com app aberto (Foreground): ${message.notification?.title}');
      if (message.notification != null) {
        showNotification(
          title: message.notification!.title ?? 'CheckVan',
          body: message.notification!.body ?? 'Você tem uma nova mensagem.',
        );
      }
    });

    // B. App em BACKGROUND (e usuário clica)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App aberto a partir da notificação (BACKGROUND): ${message.messageId}');
      _navigateToHome();
    });

    // C. App FECHADO (handler)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // --- NOVO HELPER DE NAVEGAÇÃO ---
  static void _navigateToHome() {
    // Usa a GlobalKey para navegar para a /home e limpar a pilha
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
  }

  // Método para mostrar a notificação (localmente)
  static Future<void> showNotification({
    required String title,
    required String body,
    String payload = '',
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      _channelId,
      'Lembretes CheckVan',
      channelDescription: 'Canal para lembretes de presença e rotas',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@drawable/notification_icon', // Ícone branco transparente
      largeIcon: null, // Força o Android a não usar o ícone do launcher
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(badgeNumber: 1),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}