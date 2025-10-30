import 'package:flutter/material.dart';
import '../../../utils/user_session.dart';
import '../../widgets/home/homeDriver/home_header_driver.dart';
import '../../widgets/route/nextRoute/next_route_card.dart';
import '../../widgets/route/scheduledRoutes/scheduled_routes_list.dart';

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
    // Este é o 'body' da sua HomeDriver antiga
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
              teamId: 1,
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