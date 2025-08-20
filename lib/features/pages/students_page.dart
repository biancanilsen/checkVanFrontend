import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../provider/school_provider.dart';
import '../../provider/student_provider.dart';
import '../forms/edit_student_form.dart';
import '../forms/student_form.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  // 1. REMOVA a instância local do provider daqui.
  // final StudentProvider _studentProvider = StudentProvider(); // <-- DELETAR ESTA LINHA

  @override
  void initState() {
    super.initState();
    // Esta parte já está correta, pois busca os dados no provider global.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).getStudents();
      Provider.of<SchoolProvider>(context, listen: false).getSchools();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2. REMOVA o `ChangeNotifierProvider.value`. Ele não é mais necessário.
    //    O `Consumer` e a `StudentTable` encontrarão o provider global automaticamente.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Alunos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const StudentForm(),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<StudentProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.students.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(child: Text('Erro: ${provider.error!}'));
                  }

                  if (provider.students.isEmpty) {
                    return const Center(child: Text('Nenhum aluno cadastrado.'));
                  }

                  // A StudentTable agora vai funcionar corretamente
                  return const StudentTable();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentTable extends StatelessWidget {
  const StudentTable({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final students = provider.students;

    if (provider.isLoading && students.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

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
            subtitle: Text('Nasc: ${DateFormat('dd/MM/yyyy').format(s.birthDate)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    final provider = Provider.of<StudentProvider>(context, listen: false);

                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return ChangeNotifierProvider.value(
                          value: provider,
                          child: AlertDialog(
                            title: const Text('Editar Aluno'),
                            content: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: EditStudentForm(student: s),
                            ),
                            actions: [],
                          ),
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Confirmar Exclusão'),
                          content: Text('Você tem certeza que deseja deletar o aluno(a) ${s.name}? Esta ação não pode ser desfeita.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                            TextButton(
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Confirmar'),
                              onPressed: () {
                                Provider.of<StudentProvider>(context, listen: false)
                                    .deleteStudent(s.id);
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}