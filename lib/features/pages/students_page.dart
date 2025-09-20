import 'package:flutter/material.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Alunos'),
        // A TabBar foi removida, pois a tela agora tem um único propósito
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          // A lista de alunos agora seria exibida aqui.
          // Como é um protótipo, podemos deixar um placeholder.
          Center(
            child: Text(
              'A lista de alunos cadastrados aparecerá aqui.',
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navega para a nova tela de cadastro
          Navigator.pushNamed(context, '/add-student');
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Aluno',
      ),
    );
  }
}