import 'package:flutter/material.dart';
import '../../../utils/user_session.dart';
import '../../widgets/home/homeDriver/driver_main_bottom_nav_bar.dart';
import '../../widgets/home/homeDriver/home_header_driver.dart';
import '../../widgets/menu/menu.dart';
import '../../widgets/route/nextRoute/next_route_card.dart';
import '../../widgets/route/scheduledRoutes/scheduled_routes_list.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _userName;
  bool _isLoadingUser = true;

  void _onItemTapped(int index) {
    if (index == 3) {
      _scaffoldKey.currentState?.openEndDrawer();
      return;
    }

    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/add-team');
        break;
      case 2:
        Navigator.pushNamed(context, '/van');
        break;
    }
  }

  void _onDrawerItemTapped(String routeName) {
    Navigator.pop(context); // Fecha o menu lateral (drawer)
    Navigator.pushNamed(context, routeName); // Navega para a tela clicada
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
      key: _scaffoldKey,
      endDrawer: DriverMenu(onItemTapped: _onDrawerItemTapped),
      bottomNavigationBar: MainBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: SafeArea(
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
      ),
    );
  }
}