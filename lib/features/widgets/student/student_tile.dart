import 'package:flutter/material.dart';

class StudentTile extends StatelessWidget {
  final String name;
  final String address;
  final VoidCallback onActionPressed;
  final bool isGuardian;
  final String? image_profile;

  const StudentTile({
    super.key,
    required this.name,
    required this.address,
    required this.onActionPressed,
    required this.isGuardian,
    this.image_profile,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onActionPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
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
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 3. TRAILING:
              IconButton(
                icon: Icon(
                  isGuardian ? Icons.edit_outlined : null,
                  color: Colors.grey[600],
                  size: 20,
                ),
                onPressed: onActionPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}