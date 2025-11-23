import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/tripProvider.dart';
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
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Próxima Rota',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            _buildNextRoute(tripProvider),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Rotas programadas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            _buildScheduledRoutes(tripProvider),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNextRoute(TripProvider provider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(child: Text('Erro: ${provider.error}')),
      );
    }

    return NextRouteCard(
      nextTrip: provider.nextTrip,
    );
  }

  Widget _buildScheduledRoutes(TripProvider provider) {
    if (provider.isLoading || provider.error != null) {
      return const SizedBox.shrink();
    }

    return ScheduledRoutesList(
      scheduledTrips: provider.scheduledTrips,
    );
  }
}