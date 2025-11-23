import 'dart:async';
import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/student_provider.dart';
import '../../../utils/user_session.dart';

import '../../widgets/student/add_student_button.dart';
import '../../widgets/student/student_list_content.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _userRole;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().getStudents();
      _loadUserRole();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    final user = await UserSession.getUser();
    if (mounted) {
      setState(() {
        _userRole = user?.role;
        _isLoadingRole = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<StudentProvider>().searchStudents(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool isGuardian = _userRole == 'guardian';

    return ColoredBox(
      color: AppPalette.appBackground,
      child: SafeArea(
        child: Stack(
          children: [
            StudentListContent(
              isGuardian: isGuardian,
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
            ),
            if (isGuardian) const AddStudentButton(),
          ],
        ),
      ),
    );
  }
}