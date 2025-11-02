import 'dart:async';
import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/van_provider.dart';
import '../../widgets/utils/page_header.dart';
import '../../widgets/utils/page_search_bar.dart';
import '../../widgets/van/van_tile.dart';
import 'add_van_page.dart';

class VanPage extends StatefulWidget {
  const VanPage({super.key});

  @override
  State<VanPage> createState() => _VanPageState();
}

class _VanPageState extends State<VanPage> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VanProvider>(context, listen: false).getVans();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vanProvider = context.read<VanProvider>();

    return SafeArea(
      child: Stack(
        children: [
          Consumer<VanProvider>(
            builder: (context, provider, child) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                children: [
                  const PageHeader(title: 'Minhas vans'),
                  PageSearchBar(
                    hintText: 'Pesquisar modelo ou placa',
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        provider.searchVans(value);
                      });
                    },
                  ),
                  _buildVanList(provider),
                ],
              );
            },
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nova van', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: vanProvider,
                        child: const AddVanPage(van: null), // null = Criar
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary800,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVanList(VanProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Erro: ${provider.error}"),
        ),
      );
    }

    if (provider.vans.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Nenhuma van cadastrada."),
        ),
      );
    }

    return Card(
      color: AppPalette.neutral70,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.vans.length,
        itemBuilder: (context, index) {
          final van = provider.vans[index];
          return VanTile(
            name: van.nickname,
            model: van.plate,
            plate: van.plate,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: provider,
                    child: AddVanPage(van: van),
                  ),
                ),
              );
            },
          );
        },
        separatorBuilder: (context, index) =>
            Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[200]),
      ),
    );
  }
}