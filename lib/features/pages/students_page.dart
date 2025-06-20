import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/student_provider.dart';
import '../forms/student_form.dart';

class StudentPage extends StatelessWidget {
  const StudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(''),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              StudentForm(),
              SizedBox(height: 16),
              Expanded(child: StudentTable()),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentTable extends StatelessWidget {
  const StudentTable({super.key});

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentProvider>().students;

    if (students.isEmpty) {
      return const Center(child: Text('Nenhum aluno cadastrado.'));
    }

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (_, index) {
        final s = students[index];
        return Card(
          child: ListTile(
            title: Text(s.name),
            subtitle: Text('${s.birthDate.day.toString().padLeft(2, '0')}/'
                '${s.birthDate.month.toString().padLeft(2, '0')}/${s.birthDate.year}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () {/* TODO */}),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
