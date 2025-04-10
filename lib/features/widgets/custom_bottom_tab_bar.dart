import 'package:flutter/material.dart';

class CustomBottomTabBar extends StatelessWidget {
  const CustomBottomTabBar({super.key, required this.titles});

  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.onPrimary,
      elevation: 8,
      child: TabBar(
        tabs: [
          Tab(icon: const Icon(Icons.cloud_outlined), text: titles[0]),
          Tab(icon: const Icon(Icons.beach_access_sharp), text: titles[1]),
          Tab(icon: const Icon(Icons.person), text: titles[2]),
        ],
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
