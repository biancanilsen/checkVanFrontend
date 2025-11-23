import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/student_provider.dart';
import '../../pages/student/add_student_page.dart';
import '../../widgets/student/student_tile.dart';
import '../../widgets/utils/page_header.dart';
import '../../widgets/utils/page_search_bar.dart';
import 'student_empty_state.dart';

class StudentListContent extends StatelessWidget {
  final bool isGuardian;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const StudentListContent({
    super.key,
    required this.isGuardian,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        final bool isListEmpty = provider.students.isEmpty;
        final int itemCount = isListEmpty ? 3 : provider.students.length + 2;

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 0, 16, isGuardian ? 90 : 16),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const PageHeader(title: 'Meus alunos');
            }

            if (index == 1) {
              return PageSearchBar(
                controller: searchController,
                hintText: 'Pesquisar turma ou aluno',
                onChanged: onSearchChanged,
              );
            }

            if (isListEmpty) {
              return const StudentEmptyState();
            }

            final student = provider.students[index - 2];

            return StudentTile(
              name: student.name,
              address: student.address,
              image_profile: student.image_profile,
              isGuardian: isGuardian,
              onActionPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (newContext) => ChangeNotifierProvider.value(
                      value: provider,
                      child: AddStudentPage(student: student),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}