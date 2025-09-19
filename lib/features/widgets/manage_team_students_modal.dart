import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/student_model.dart';
import '../../model/team_model.dart';
import '../../provider/student_provider.dart';
import '../../provider/team_provider.dart';

class ManageTeamStudentsModal extends StatefulWidget {
  final Team team;
  const ManageTeamStudentsModal({required this.team, super.key});

  @override
  State<ManageTeamStudentsModal> createState() => _ManageTeamStudentsModalState();
}

class _ManageTeamStudentsModalState extends State<ManageTeamStudentsModal> {
  Key _autocompleteKey = UniqueKey();
  List<Student> _teamStudents = [];
  List<Student> _allStudentsForSearch = [];
  Student? _selectedStudent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // --- MÉTODO CORRIGIDO ---
  /// Busca os dados iniciais: alunos da turma e todos os alunos para a busca.
  Future<void> _fetchData() async {
    // Garante que o estado de loading seja ativado no início
    if (mounted) setState(() => _isLoading = true);

    // Acessa os providers para buscar os dados
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);

    // Usa Future.wait para executar as duas buscas de dados em paralelo
    final results = await Future.wait([
      teamProvider.getStudentsForTeam(widget.team.id),
      studentProvider.getAllStudentsForDriver(),
    ]);

    // Após a conclusão, atualiza o estado se o widget ainda estiver montado
    if (mounted) {
      setState(() {
        _teamStudents = results[0] as List<Student>;
        _allStudentsForSearch = results[1] as List<Student>;
        _isLoading = false; // <-- Ponto crucial: finaliza o estado de loading
      });
    }
  }

  void _assignStudent() async {
    if (_selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um aluno da lista.')),
      );
      return;
    }

    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    final success = await teamProvider.assignStudentToTeam(
      studentId: _selectedStudent!.id,
      teamId: widget.team.id,
    );

    if (success) {
      // Limpa a seleção e recria o Autocomplete
      setState(() {
        _selectedStudent = null;
        _autocompleteKey = UniqueKey();
      });

      // Recarrega a lista de alunos da turma para exibir o novo membro
      final updatedStudents = await teamProvider.getStudentsForTeam(widget.team.id);
      if(mounted) setState(() => _teamStudents = updatedStudents);

    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(teamProvider.error ?? 'Erro ao atribuir aluno')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.team.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Autocomplete<Student>(
                  key: _autocompleteKey,
                  displayStringForOption: (Student option) => option.name,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Student>.empty();
                    }
                    return _allStudentsForSearch.where((Student student) {
                      final studentAlreadyInTeam = _teamStudents.any((s) => s.id == student.id);
                      final nameMatches = student.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      return nameMatches && !studentAlreadyInTeam;
                    });
                  },
                  onSelected: (Student selection) {
                    setState(() => _selectedStudent = selection);
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _assignStudent,
                style: ElevatedButton.styleFrom(
                  // Cor de fundo do botão
                  backgroundColor: Colors.green,
                  // Cor do ícone
                  foregroundColor: Colors.white,
                  // Remove a sombra para um visual mais limpo
                  elevation: 2,
                  // Define o formato com bordas bem arredondadas
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // Define um tamanho fixo para o botão
                  minimumSize: const Size(50, 50),
                  padding: EdgeInsets.zero, // Remove o padding interno para centralizar o ícone
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text('Alunos na Turma (${_teamStudents.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _teamStudents.isEmpty
                ? const Center(child: Text('Nenhum aluno nesta turma.'))
                : ListView.builder(
              itemCount: _teamStudents.length,
              itemBuilder: (context, index) {
                final student = _teamStudents[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(student.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      tooltip: 'Remover Aluno',
                      onPressed: () {
                        // Exibe um dialog de confirmação
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Confirmar Remoção'),
                            content: Text('Deseja realmente remover ${student.name} da turma ${widget.team.name}?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancelar'),
                                onPressed: () => Navigator.of(dialogContext).pop(),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Remover'),
                                onPressed: () async {
                                  // Fecha o dialog primeiro
                                  Navigator.of(dialogContext).pop();

                                  // Chama o provider para desvincular o aluno
                                  final success = await Provider.of<TeamProvider>(context, listen: false)
                                      .unassignStudentFromTeam(
                                      studentId: student.id,
                                      teamId: widget.team.id
                                  );

                                  // Se a remoção for bem-sucedida, atualiza a lista na tela
                                  if (success) {
                                    _fetchData();
                                  } else {
                                    // Mostra mensagem de erro vinda do provider
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(Provider.of<TeamProvider>(context, listen: false).error ?? 'Erro ao remover aluno')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}