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

    const double cardHeight = 265;
    const double mapVisibilityRatio = 0.3;

    final bool hasTrip = nextTrip != null;
    final int? teamId = nextTrip?.teamId;
    final String rota = nextTrip?.rota ?? 'Nenhuma rota futura';
    final String alunos = nextTrip?.quantidadeAlunos.toString() ?? '0';
    final String comecaEm = nextTrip?.comecaEm ?? '--';
    final String horario = nextTrip?.horarioInicio ?? '--';

    final bool isGoing = nextTrip?.tipo == 'Ida';
    final IconData icon = isGoing ? Icons.wb_sunny_outlined : Icons.brightness_6_outlined;
    final Color chipBgColor = isGoing ? AppPalette.orange100 : AppPalette.primary50;
    final Color chipTextColor = isGoing ? AppPalette.orange700 : AppPalette.primary900;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 1.0,
        shadowColor: Colors.black.withOpacity(0.1),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Container(
              height: cardHeight,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/rota.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: cardHeight,
              padding: EdgeInsets.fromLTRB(
                12,
                (cardHeight * mapVisibilityRatio) + 12,
                12,
                12,
              ),
              child: Column(
                children: [
                  // --- CABEÇALHO (Nome da Rota) ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasTrip) ...[
                          Icon(icon, size: 18, color: Colors.black87),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          rota,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- INFORMAÇÕES (Alunos e Horário) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alunos',
                            style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              alunos,
                              style: const TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.w700),
                            ),
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
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: hasTrip ? chipBgColor : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              comecaEm,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: hasTrip ? chipTextColor : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // --- BOTÃO DE INICIAR ROTA ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (routeProviderLoading || !hasTrip)
                          ? null
                          : () async {
                        // 1. Determina o tipo (Backend espera 'GOING' ou 'RETURNING')
                        final String tripTypeParam = isGoing ? 'GOING' : 'RETURNING';

                        // 2. Determina a data
                        final DateTime tripDate = nextTrip!.sortTime != null
                            ? DateTime.fromMillisecondsSinceEpoch(nextTrip!.sortTime!)
                            : DateTime.now();

                        // 3. Captura Localização Atual
                        LatLng? currentLoc;
                        try {
                          final location = Location();

                          // Verifica/Solicita permissão se necessário
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
                          print("Erro ao obter localização para gerar rota: $e");
                          // Segue sem localização (backend usará o padrão da garagem)
                        }

                        // 4. Chama o Provider
                        final success = await routeProvider.generateRoute(
                          teamId: teamId!,
                          tripType: tripTypeParam,
                          date: tripDate,
                          currentLocation: currentLoc, // Envia a localização
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
                        foregroundColor: AppPalette.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: routeProviderLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: AppPalette.white, strokeWidth: 3),
                      )
                          : const Text(
                        'Iniciar rota',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}