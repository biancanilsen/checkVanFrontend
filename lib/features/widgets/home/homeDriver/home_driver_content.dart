import 'package:check_van_frontend/features/widgets/home/homeDriver/scheduled_routes_section.dart';
import 'package:check_van_frontend/features/widgets/home/homeDriver/section_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../provider/tripProvider.dart';
import '../../../../utils/user_session.dart';
import 'driver_home_header.dart';
import 'next_route_section.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().fetchNextTrips();
    });
  }

  Future<void> _loadUserName() async {
    final user = await UserSession.getUser();
    if (mounted) {
      setState(() {
        _userName = user?.name;
        _profileImageUrl = user?.imageProfile;
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _navigateToProfile() async {
    await Navigator.pushNamed(context, '/my_profile');
    _loadUserName();
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DriverHomeHeader(
              isLoading: _isLoadingUser,
              userName: _userName,
              imageProfile: _profileImageUrl,
              onProfileTap: _navigateToProfile,
            ),

            const SectionTitle(title: 'Próxima Rota'),

            NextRouteSection(provider: tripProvider),

            const SectionTitle(
              title: 'Rotas programadas',
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            ),

            ScheduledRoutesSection(provider: tripProvider),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}