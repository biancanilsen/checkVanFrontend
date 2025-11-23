import 'package:flutter/material.dart';

import '../../../../core/theme.dart';

class RouteStopTile extends StatelessWidget {
  final String name;
  final String address;
  final bool isLastStop;
  final bool isNextTarget;
  final String? imageUrl;
  final bool isSchool;
  final VoidCallback? onTap;
  final String? etaBadge;

  const RouteStopTile({
    super.key,
    required this.name,
    required this.address,
    required this.isLastStop,
    required this.isNextTarget,
    this.imageUrl,
    this.isSchool = false,
    this.onTap,
    this.etaBadge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                      isSchool ? Icons.school : Icons.location_on,
                      color: isSchool ? AppPalette.primary800 : AppPalette.red700,
                      size: 28
                  ),
                  if (!isLastStop)
                    Expanded(
                      child: Container(width: 2, color: AppPalette.neutral300),
                    )
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                        ? NetworkImage(imageUrl!)
                        : const AssetImage('assets/profile.png') as ImageProvider,
                    backgroundColor: isSchool ? AppPalette.primary800 : AppPalette.neutral150,
                    child: (imageUrl == null && isSchool)
                        ? const Icon(Icons.school, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                            address,
                            style: TextStyle(
                                color: isNextTarget ? AppPalette.primary800 : AppPalette.neutral600,
                                fontSize: 12,
                                fontWeight: FontWeight.normal
                            )
                        ),
                      ],
                    ),
                  ),
                  if (etaBadge != null)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        etaBadge!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppPalette.primary900),
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}