// lib/features/pages/home/route/scheduledRoutes/scheduled_routes_list.dart
import 'package:check_van_frontend/core/theme.dart';
import 'package:check_van_frontend/features/widgets/route/scheduledRoutes/scheduled_route_card.dart';
import 'package:flutter/material.dart';

import '../../../../../model/trip_model.dart'; // Import o novo model
import '../../home/pageIndicator/page_indicator.dart';

class ScheduledRoutesList extends StatefulWidget {
  // Recebe a lista de viagens
  final List<Trip> scheduledTrips;

  const ScheduledRoutesList({
    super.key,
    required this.scheduledTrips, // <--- Parâmetro 'scheduledTrips'
  });

  @override
  State<ScheduledRoutesList> createState() => _ScheduledRoutesListState();
}

class _ScheduledRoutesListState extends State<ScheduledRoutesList> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;

  final double _cardWidthFraction = 0.75;
  final double _cardSpacing = 12.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    double cardWidth = MediaQuery.of(context).size.width * _cardWidthFraction;
    double cardWithSpacing = cardWidth + _cardSpacing;
    double offset = _scrollController.offset;
    int newPage = (offset + (cardWithSpacing / 2)) ~/ cardWithSpacing;

    if (newPage != _currentPage) {
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE DADOS ---
    final List<Trip> trips = widget.scheduledTrips;

    // Se não houver viagens, mostra uma mensagem
    if (trips.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Text(
            'Nenhuma outra rota programada para hoje.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            // Mapeia a lista de Trips para os Widgets
            children: List.generate(trips.length, (index) {
              final trip = trips[index];

              // Define o ícone e cores com base no tipo
              final IconData icon = trip.tipo == 'Ida'
                  ? Icons.wb_sunny_outlined
                  : Icons.brightness_6_outlined;
              final Color chipBgColor = trip.tipo == 'Ida'
                  ? AppPalette.orange100
                  : AppPalette.primary50;
              final Color chipTextColor = trip.tipo == 'Ida'
                  ? AppPalette.orange700
                  : AppPalette.primary900;

              return Padding(
                padding: EdgeInsets.only(
                  right: (index == trips.length - 1) ? 0 : _cardSpacing,
                ),
                // Constrói o card com os dados da viagem
                child: ScheduledRouteCard(
                  routeName: trip.rota,
                  studentCount: trip.quantidadeAlunos.toString(),
                  startTime: trip.horarioInicio,
                  icon: icon,
                  chipBgColor: chipBgColor,
                  chipTextColor: chipTextColor,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        PageIndicator(
          itemCount: trips.length,
          currentIndex: _currentPage,
        ),
      ],
    );
  }
}