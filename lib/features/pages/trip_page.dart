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
    // A lógica para buscar os dados na inicialização permanece a mesma
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripProvider>(context, listen: false).getTrips();
    });
  }

  // Método que abre o Bottom Sheet com o formulário
  void _openAddTripSheet() {
    showModalBottomSheet(
      context: context,
      // Permite que o sheet seja rolável e ocupe mais espaço
      isScrollControlled: true,
      // Define o formato com cantos arredondados
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        // O conteúdo do Bottom Sheet é o nosso TripForm
        return const Padding(
          padding: EdgeInsets.all(16.0),
          // O TripForm já tem a lógica de cadastro
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
      // O corpo agora é apenas a lista
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Um padding geral
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

            // A Lista de Viagens usando o TripExpansionTile
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
      // Botão flutuante para adicionar nova viagem
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTripSheet,
        child: const Icon(Icons.add),
        tooltip: 'Cadastrar Nova Viagem',
      ),
    );
  }
}