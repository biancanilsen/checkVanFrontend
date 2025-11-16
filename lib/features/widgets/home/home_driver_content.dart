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
    // Busca as viagens ao iniciar a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().fetchNextTrips();
    });
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
    // Escuta o TripProvider para atualizações na UI
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

            // --- CONTEÚDO DINÂMICO ---
            // Constrói o card "Próxima Rota" com base no estado do provider
            _buildNextRoute(tripProvider),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Rotas programadas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // --- CONTEÚDO DINÂMICO ---
            // Constrói a lista "Rotas programadas" com base no estado do provider
            _buildScheduledRoutes(tripProvider),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Helper para construir o card da próxima rota
  Widget _buildNextRoute(TripProvider provider) {
    if (provider.isLoading) {
      // Mostra um loading no lugar do card
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.error != null) {
      // Mostra uma mensagem de erro no lugar do card
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(child: Text('Erro: ${provider.error}')),
      );
    }

    // Passa a próxima viagem (pode ser null se não houver)
    return NextRouteCard(
      nextTrip: provider.nextTrip,
    );
  }

  /// Helper para construir a lista de rotas programadas
  Widget _buildScheduledRoutes(TripProvider provider) {
    // Se estiver carregando ou com erro, não mostra a lista
    // (o _buildNextRoute já vai mostrar o status)
    if (provider.isLoading || provider.error != null) {
      return const SizedBox.shrink();
    }

    // Passa a lista de viagens programadas (pode estar vazia)
    return ScheduledRoutesList(
      scheduledTrips: provider.scheduledTrips,
    );
  }
}