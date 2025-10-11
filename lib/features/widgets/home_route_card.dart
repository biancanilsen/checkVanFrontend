import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/route_provider.dart';
import '../../core/theme.dart';

class HomeRouteCard extends StatelessWidget {
  final int teamId;
  
  const HomeRouteCard({
    super.key,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<RouteProvider>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: routeProvider.isLoading
            ? null
            : () async {
                final success = await routeProvider.generateRoute(teamId: teamId);
                if (success && context.mounted) {
                  Navigator.pushNamed(
                    context,
                    '/route',
                    arguments: routeProvider.routeData,
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(routeProvider.error ?? 'Erro ao gerar rota'),
                      backgroundColor: AppPalette.red500,
                    ),
                  );
                }
              },
          child: Stack(
            children: [
              Column(
                children: [
                  Image.asset(
                    'assets/rota_gps.png',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      DateTime.now().add(const Duration(days: 1))
                          .toLocal()
                          .toString()
                          .split(' ')[0],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (routeProvider.isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
