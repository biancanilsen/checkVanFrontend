import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../provider/school_provider.dart';
import '../../pages/school/add_school_page.dart';

class AddSchoolButton extends StatelessWidget {
  final SchoolProvider schoolProvider;

  const AddSchoolButton({super.key, required this.schoolProvider});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Nova escola',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: schoolProvider,
                  child: const AddSchoolPage(school: null),
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
    );
  }
}