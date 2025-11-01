import 'package:flutter/material.dart';
import '../../widgets/home/home_driver_content.dart';
import '../team/teams_page.dart';
import '../van/van_page.dart';
import '../student/students_page.dart';
import '../school/school_page.dart';
import '../profile/my_profile.dart';

import '../../widgets/home/homeDriver/driver_main_bottom_nav_bar.dart';
import '../../widgets/menu/menu.dart';

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

  static const List<Widget> _navBarPages = [
    HomeDriverContent(),
    TeamsPage(),
    VanPage(),
  ];

  late Widget _currentBody;

  @override
  void initState() {
    super.initState();
    _currentBody = _navBarPages[0];
  }

  void _onBottomNavItemTapped(int index) {
    // Se for o botão 'Menu'
    if (index == 3) {
      _scaffoldKey.currentState?.openEndDrawer();
      return;
    }

    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
      _currentBody = _navBarPages[index];
    });
  }

  void _onDrawerItemTapped(String routeName) {
    Navigator.pop(context); // Fecha o menu lateral
    Widget newPage;

    int newIndex = -1;

    switch (routeName) {
      case '/my_profile':
        newPage = const MyProfile();
        break;
      case '/students':
        newPage = const StudentPage();
        break;
      case '/schools':
        newPage = const SchoolPage();
        break;
      case '/vans':
        newPage = _navBarPages[2];
        newIndex = 2;
        break;
      default:
        newPage = _navBarPages[0];
        newIndex = 0;
    }

    setState(() {
      _currentBody = newPage;
      _selectedIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: DriverMenu(onItemTapped: _onDrawerItemTapped),
      bottomNavigationBar: DriverBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onBottomNavItemTapped,
      ),
      body: _currentBody,
    );
  }
}