import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart'; // Importe o pacote de localização
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Importe para LatLng

import 'package:provider/provider.dart';
import 'package:check_van_frontend/provider/route_provider.dart';

import '../../../../../model/trip_model.dart';

class NextRouteCard extends StatelessWidget {
  final Trip? nextTrip;

  const NextRouteCard({
    super.key,
    this.nextTrip,
  });

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.read<RouteProvider>();
    final routeProviderLoading = context.watch<RouteProvider>().isLoading;

    const double cardHeight = 320;

    const double whiteBoxTopPosition = cardHeight * 0.35;

    final bool hasTrip = nextTrip != null;
    final int? teamId = nextTrip?.teamId;
    final String rota = nextTrip?.rota ?? 'Nenhuma rota futura';
    final String alunos = nextTrip?.quantidadeAlunos.toString() ?? '0';
    final String comecaEm = nextTrip?.comecaEm ?? '--';
    final String horario = nextTrip?.horarioInicio ?? '--';

    final bool isGoing = nextTrip?.tipo == 'Ida';
    final IconData icon = isGoing ? Icons.wb_sunny_outlined : Icons.brightness_6_outlined;

    final Color chipBgColor = AppPalette.orange100;
    final Color chipTextColor = AppPalette.orange700;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
              color: AppPalette.neutral50,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: cardHeight * 0.6,
                child: Image.asset(
                  'assets/rota.png',
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(color: AppPalette.primary100),
                ),
              ),

              Positioned(
                top: whiteBoxTopPosition,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.60),
                    // Borda arredondada apenas no topo para criar o efeito de "folha"
                    // borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (hasTrip) ...[
                            Icon(icon, size: 20, color: Colors.black87),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            rota,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start, // Alinha ao topo
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Alunos',
                                style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                alunos,
                                style: const TextStyle(fontSize: 28, color: Colors.black87, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                hasTrip ? 'Início ($horario)' : 'Início',
                                style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 8),
                              // Chip de tempo (ex: Em 5 min)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: hasTrip ? chipBgColor : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  comecaEm,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: hasTrip ? chipTextColor : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (routeProviderLoading || !hasTrip)
                              ? null
                              : () async {
                            final String tripTypeParam = isGoing ? 'GOING' : 'RETURNING';
                            final DateTime tripDate = nextTrip!.sortTime != null
                                ? DateTime.fromMillisecondsSinceEpoch(nextTrip!.sortTime!)
                                : DateTime.now();

                            LatLng? currentLoc;
                            try {
                              final location = Location();
                              bool serviceEnabled = await location.serviceEnabled();
                              if (!serviceEnabled) {
                                serviceEnabled = await location.requestService();
                              }
                              if (serviceEnabled) {
                                PermissionStatus permissionGranted = await location.hasPermission();
                                if (permissionGranted == PermissionStatus.denied) {
                                  permissionGranted = await location.requestPermission();
                                }
                                if (permissionGranted == PermissionStatus.granted) {
                                  final locData = await location.getLocation();
                                  if (locData.latitude != null && locData.longitude != null) {
                                    currentLoc = LatLng(locData.latitude!, locData.longitude!);
                                  }
                                }
                              }
                            } catch (e) {
                              debugPrint("Erro ao obter localização: $e");
                            }

                            final success = await routeProvider.generateRoute(
                              teamId: teamId!,
                              tripType: tripTypeParam,
                              date: tripDate,
                              currentLocation: currentLoc,
                            );

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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.primary800,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          child: routeProviderLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                              : const Text('Iniciar rota'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}