import 'package:flutter/material.dart';
import '../../utils/user_session.dart';
import '../widgets/ScheduledRoutes/scheduled_routes_list.dart';
import '../widgets/main_bottom_nav_bar.dart';
import '../widgets/nextRoute/next_route_card.dart';
import '../widgets/home/home_header_driver.dart';

class HomeDriver extends StatelessWidget {
  const HomeDriver({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeDriverView();
  }
}

class _HomeDriverView extends StatefulWidget {
  const _HomeDriverView();

  @override
  State<_HomeDriverView> createState() => _HomeDriverViewState();
}

class _HomeDriverViewState extends State<_HomeDriverView> {
  int _selectedIndex = 0;
  String? _userName;
  bool _isLoadingUser = true;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/students');
        break;
      case 2:
        Navigator.pushNamed(context, '/van');
        break;
      case 3:
        Navigator.pushNamed(context, '/my_profile');
        break;
    }
  }

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
    return Scaffold(
      // 2. SUBSTITUA O BottomNavigationBar
      bottomNavigationBar: MainBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3. SUBSTITUA O _buildHeader()
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
                teamId: 3,
              ),

              // 4. Título "Rotas programadas"
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Rotas programadas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // 5. Lista Horizontal Mocado "Rotas programadas"
              const ScheduledRoutesList(),
              const SizedBox(height: 20), // Espaçamento no final
            ],
          ),
        ),
      ),
    );
  }
}