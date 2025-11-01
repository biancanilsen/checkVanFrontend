import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/school_provider.dart';
import '../../widgets/school/school_tile.dart';
import '../../widgets/utils/page_header.dart';
import '../../widgets/utils/page_search_bar.dart';

class SchoolPage extends StatefulWidget {
  const SchoolPage({super.key});

  @override
  State<SchoolPage> createState() => _SchoolPageState();
}

class _SchoolPageState extends State<SchoolPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolProvider>(context, listen: false).getSchools();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Consumer<SchoolProvider>(
            builder: (context, provider, child) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                children: [
                  const PageHeader(title: 'Minhas escolas'),
                  PageSearchBar(
                    hintText: 'Pesquisar escola',
                    onChanged: (value) {
                      // TODO: Implementar lógica de filtro no provider
                      // provider.filterSchools(value);
                    },
                  ),
                  _buildSchoolList(provider),
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
                label: const Text('Nova escola',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  Navigator.pushNamed(context, '/add-school');
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

  Widget _buildSchoolList(SchoolProvider provider) {
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

    if (provider.schools.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Nenhuma escola cadastrada."),
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
        itemCount: provider.schools.length,
        itemBuilder: (context, index) {
          final school = provider.schools[index];
          return SchoolTile(
            name: school.name,
            address: school.address ?? 'Endereço não cadastrado',
            onTap: () {
              /* Ação "Ver detalhes da escola" */
            },
          );
        },
        separatorBuilder: (context, index) =>
            Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[200]),
      ),
    );
  }
}