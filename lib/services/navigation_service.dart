import 'package:flutter/material.dart';

// Chave global para acessar o Navigator sem context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NavigationService {
  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> replaceTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  static void goBack() {
    return navigatorKey.currentState!.pop();
  }

  // Remove todas as rotas e vai para a de erro
  static void forceErrorScreen() {
    // Só navega se já não estiver na tela de erro para evitar loops
    bool isAlreadyOnThePage = false;
    navigatorKey.currentState?.popUntil((route) {
      if (route.settings.name == '/server-error') {
        isAlreadyOnThePage = true;
      }
      return true;
    });

    if (!isAlreadyOnThePage) {
      navigatorKey.currentState!.pushNamed('/server-error');
    }
  }
}