import 'package:flutter/material.dart';

// Esta chave global permite-nos aceder ao estado do Navigator
// de qualquer parte da aplicação, sem precisar de um BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();