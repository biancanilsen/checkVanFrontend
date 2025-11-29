import 'package:flutter/material.dart';
import 'package:check_van_frontend/core/theme.dart';

class StudentListItem extends StatelessWidget {
  final int index;
  final String name;
  final String address;
  final IconData? trailIcon;
  final Color? trailIconColor;
  final String? image_profile;

  const StudentListItem({
    super.key,
    required this.index,
    required this.name,
    required this.address,
    this.trailIcon,
    this.trailIconColor,
    this.image_profile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
      child: Row(
        children: [
          Text(
            (index).toString(),
            style: const TextStyle(
              fontSize: 20,
              color: AppPalette.neutral800,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 24, // Um pouco menor que o anterior
            backgroundColor: AppPalette.neutral200,
            backgroundImage: (image_profile != null && image_profile!.isNotEmpty)
                ? NetworkImage(image_profile!)
                : const AssetImage('assets/profile.png') as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: AppPalette.neutral600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (trailIcon != null)
            Icon(
              trailIcon,
              color: trailIconColor ?? AppPalette.orange700,
              size: 24,
            ),
        ],
      ),
    );
  }
}