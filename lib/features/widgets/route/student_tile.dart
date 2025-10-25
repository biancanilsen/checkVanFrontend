import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/theme.dart';

class StudentTile extends StatelessWidget {
  final int index;
  final String name;
  final String address;
  final bool isConfirmed;

  const StudentTile({
    super.key,
    required this.index,
    required this.name,
    required this.address,
    required this.isConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppPalette.neutral200,
                  backgroundImage:
                  const AssetImage('assets/retratoCrianca.webp'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
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
          SvgPicture.asset(
            isConfirmed ? 'assets/icons/check.svg' : 'assets/icons/cross.svg',
            width: 21,
          ),
        ],
      ),
    );
  }
}