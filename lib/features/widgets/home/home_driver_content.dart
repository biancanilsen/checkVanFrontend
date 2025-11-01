// Salve como: /lib/features/widgets/home/homeDriver/home_driver_content.dart
import 'package:flutter/material.dart';
import '../../../utils/user_session.dart';
import '../route/nextRoute/next_route_card.dart';
import '../route/scheduledRoutes/scheduled_routes_list.dart';
import 'homeDriver/home_header_driver.dart';

class HomeDriverContent extends StatefulWidget {
  const HomeDriverContent({super.key});

  @override
  State<HomeDriverContent> createState() => _HomeDriverContentState();
}

class _HomeDriverContentState extends State<HomeDriverContent> {
  String? _userName;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = await UserSession.getUser();
    if (mounted) {
      setState(() {
        _userName = user?.name;
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Este é o conteúdo que estava antes no body do HomeDriver
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(
              isLoading: _isLoadingUser,
              userName: _userName,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Próxima Rota',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            NextRouteCard(
              teamId: 1, // Você pode precisar tornar isso dinâmico
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Rotas programadas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const ScheduledRoutesList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}