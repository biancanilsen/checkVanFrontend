import 'package:flutter/material.dart';
import '../../../utils/user_session.dart';
import '../route/nextRoute/next_route_card.dart';
import '../route/scheduledRoutes/scheduled_routes_list.dart';
import 'homeDriver/driver_home_header.dart';

class HomeDriverContent extends StatefulWidget {
  const HomeDriverContent({super.key});

  @override
  State<HomeDriverContent> createState() => _HomeDriverContentState();
}

class _HomeDriverContentState extends State<HomeDriverContent> {
  String? _userName;
  bool _isLoadingUser = true;
  String? _profileImageUrl;

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
        // TODO _profileImageUrl = imageUrl; // Salve a URL da imagem
      });
    }
  }

  Future<void> _navigateToProfile() async {
    await Navigator.pushNamed(context, '/my_profile');

    _loadUserName();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DriverHomeHeader(
              isLoading: _isLoadingUser,
              userName: _userName, imageProfile: _profileImageUrl, onProfileTap: _navigateToProfile,
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