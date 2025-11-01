import 'package:flutter/material.dart';
import '../../pages/profile/my_profile.dart';
import '../../pages/school/school_page.dart';
import '../../pages/student/students_page.dart';
import '../../pages/team/teams_page.dart';
import '../../pages/van/van_page.dart';
import '../../widgets/home/homeDriver/driver_main_bottom_nav_bar.dart';
import '../menu/menu.dart';
import 'home_driver_content.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({super.key});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<Widget> _navBarPages = [
    HomeDriverContent(), // Antiga HomeDriver
    TeamsPage(),       // 'Turmas'
    VanPage(),           // 'Mensagens'
  ];

  late Widget _currentBody;

  @override
  void initState() {
    super.initState();
    _currentBody = _navBarPages[0];
  }

  void _onBottomNavItemTapped(int index) {
    if (index == 3) {
      _scaffoldKey.currentState?.openEndDrawer();
      return;
    }

    setState(() {
      _selectedIndex = index;
      _currentBody = _navBarPages[index];
    });
  }

  void _onDrawerItemTapped(String routeName) {
    Navigator.pop(context);
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
        _onBottomNavItemTapped(2);
        return;
      default:
        newPage = _navBarPages[0];
        newIndex = 0;
    }

    setState(() {
      _currentBody = newPage;
      _selectedIndex = (newIndex == -1) ? 0 : newIndex;
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