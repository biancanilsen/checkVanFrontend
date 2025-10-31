import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class SchoolTile extends StatelessWidget {
  final String name;
  final String address;
  final VoidCallback onTap;

  const SchoolTile({
    super.key,
    required this.name,
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.menu_book_outlined, color: Colors.grey[700]),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppPalette.primary900),
      ),
      subtitle: Text(
        address,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[700]),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
      onTap: onTap,
    );
  }
}