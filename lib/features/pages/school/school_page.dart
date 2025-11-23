import 'dart:async';

import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/school_provider.dart';
import '../../widgets/school/add_school_button.dart';
import '../../widgets/school/school_list_content.dart';
import '../../widgets/utils/page_header.dart';
import '../../widgets/utils/page_search_bar.dart';

class SchoolPage extends StatefulWidget {
  const SchoolPage({super.key});

  @override
  State<SchoolPage> createState() => _SchoolPageState();
}

class _SchoolPageState extends State<SchoolPage> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolProvider>(context, listen: false).getSchools();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schoolProvider = context.watch<SchoolProvider>();

    return ColoredBox(
      color: AppPalette.appBackground,
      child: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              children: [
                const PageHeader(title: 'Minhas escolas'),
                PageSearchBar(
                  hintText: 'Pesquisar escola',
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      schoolProvider.searchSchools(value);
                    });
                  },
                ),
                SchoolListContent(provider: schoolProvider),
              ],
            ),

            AddSchoolButton(schoolProvider: schoolProvider),
          ],
        ),
      ),
    );
  }
}