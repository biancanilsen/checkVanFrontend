import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String title;

  const PageHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
      child: Text(
        title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppPalette.primary900),
        textAlign: TextAlign.center,
      ),
    );
  }
}