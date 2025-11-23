import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../provider/school_provider.dart';
import '../../pages/school/add_school_page.dart';
import '../../widgets/school/school_tile.dart';

class SchoolListContent extends StatelessWidget {
  final SchoolProvider provider;

  const SchoolListContent({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: provider,
                    child: AddSchoolPage(school: school),
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