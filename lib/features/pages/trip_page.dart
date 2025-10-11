// lib/view/pages/trip_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/trip_provider.dart';
import '../forms/trip_form.dart';
import '../widgets/trip_expansion_tile.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripProvider>(context, listen: false).getTrips();
    });
  }

  void _openAddTripSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: TripForm(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Viagens'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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

            return ListView.builder(
              itemCount: provider.trips.length,
              itemBuilder: (context, index) {
                final trip = provider.trips[index];
                return TripExpansionTile(trip: trip);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTripSheet,
        child: const Icon(Icons.add),
        tooltip: 'Cadastrar nova viagem',
      ),
    );
  }
}