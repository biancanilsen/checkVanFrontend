import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/trip_provider.dart';
import '../forms/trip_form.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  @override
  void initState() {
    super.initState();
    // Usa um callback pós-frame para garantir que o provider seja acessado após a construção inicial.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripProvider>(context, listen: false).getTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Viagens'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TripForm(),
            const SizedBox(height: 24),
            const Text("Viagens Cadastradas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: Consumer<TripProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.trips.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.error != null) {
                    return Center(child: Text(provider.error!));
                  }
                  if (provider.trips.isEmpty) {
                    return const Center(child: Text('Nenhuma viagem cadastrada.'));
                  }

                  // A Lista de Viagens
                  return ListView.builder(
                    itemCount: provider.trips.length,
                    itemBuilder: (context, index) {
                      final trip = provider.trips[index];
                      // Usando ExpansionTile para o efeito "Acordeão"
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ExpansionTile(
                          title: Text('${trip.startingPoint} -> ${trip.endingPoint}'),
                          subtitle: Text('Saída: ${trip.departureTime}'),
                          children: <Widget>[
                            ListTile(
                              title: const Text('Ponto de Partida'),
                              subtitle: Text(trip.startingPoint),
                              leading: const Icon(Icons.trip_origin),
                            ),
                            ListTile(
                              title: const Text('Ponto de Chegada'),
                              subtitle: Text(trip.endingPoint),
                              leading: const Icon(Icons.location_on),
                            ),
                            ListTile(
                              title: const Text('Horário de Chegada'),
                              subtitle: Text(trip.arrivalTime),
                              leading: const Icon(Icons.timer_outlined),
                            ),
                            // Você pode adicionar botões de editar/deletar aqui
                            ButtonBar(
                              children: [
                                TextButton(onPressed: () {}, child: const Text('EDITAR')),
                                TextButton(onPressed: () {}, child: const Text('DELETAR')),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}