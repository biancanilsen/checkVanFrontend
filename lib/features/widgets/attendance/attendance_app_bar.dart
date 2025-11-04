import 'package:flutter/material.dart';

class AttendanceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String studentName;
  final String? studentImageUrl;

  const AttendanceAppBar({
    Key? key,
    required this.studentName,
    this.studentImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight + 40),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade200,
                child: ClipOval(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: (studentImageUrl != null && studentImageUrl!.isNotEmpty)
                        ? NetworkImage(studentImageUrl!)
                        : const AssetImage('assets/profile.png') as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                studentName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 60);
}