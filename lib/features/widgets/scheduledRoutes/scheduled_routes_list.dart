import 'package:check_van_frontend/core/theme.dart';
import 'package:check_van_frontend/features/widgets/ScheduledRoutes/scheduled_route_card.dart';
import 'package:flutter/material.dart';

import '../page_indicator.dart';

class ScheduledRoutesList extends StatefulWidget {
  const ScheduledRoutesList({super.key});

  @override
  State<ScheduledRoutesList> createState() => _ScheduledRoutesListState();
}

class _ScheduledRoutesListState extends State<ScheduledRoutesList> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;

  final List<ScheduledRouteCard> _cards = [
    ScheduledRouteCard(
      routeName: 'Rota da tarde',
      studentCount: '14',
      startTime: 'Às 11h',
      icon: Icons.brightness_6_outlined,
      chipBgColor: AppPalette.primary50,
      chipTextColor: AppPalette.primary900,
    ),
    ScheduledRouteCard(
      routeName: 'Rota da noite',
      studentCount: '9',
      startTime: 'Às 18h',
      icon: Icons.dark_mode_outlined,
      chipBgColor: Colors.purple.shade100,
      chipTextColor: Colors.purple.shade800,
    ),
  ];

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
    return Column(
      children: [
        // A lista de scroll (sem alterações)
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: List.generate(_cards.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: (index == _cards.length - 1) ? 0 : _cardSpacing,
                ),
                child: _cards[index],
              );
            }),
          ),
        ),

        const SizedBox(height: 16),

        // 3. Substitua a Row de bolinhas pelo novo Widget
        PageIndicator(
          itemCount: _cards.length,
          currentIndex: _currentPage,
        ),
      ],
    );
  }
}