import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/van_provider.dart';
import '../../widgets/utils/page_header.dart';
import '../../widgets/utils/page_search_bar.dart';

import '../../widgets/van/van_list_content.dart';
import 'add_van_button.dart';

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
                  VanListContent(provider: provider),
                ],
              );
            },
          ),

          AddVanButton(vanProvider: vanProvider),
        ],
      ),
    );
  }
}