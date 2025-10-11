import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/home_provider.dart';
import '../../provider/team_provider.dart'; // Importe o TeamProvider
import '../../utils/user_session.dart';
import '../widgets/home_header.dart';
import '../widgets/home_menu_button.dart';
import '../widgets/home_route_card.dart';

class HomeDriver extends StatelessWidget {
  const HomeDriver({super.key});

  @override
  Widget build(BuildContext context) {
    // O ChangeNotifierProvider foi movido para o main.dart,
    // então a HomeProvider já está disponível aqui.
    return const _HomeDriverView();
  }
}

class _HomeDriverView extends StatefulWidget {
  const _HomeDriverView();

  @override
  State<_HomeDriverView> createState() => _HomeDriverViewState();
}

class _HomeDriverViewState extends State<_HomeDriverView> {
  @override
  void initState() {
    super.initState();
    // Busca os dados das turmas assim que a tela é construída
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamProvider>(context, listen: false).getTeams();
    });
  }

  void _logout(BuildContext context) async {
    await UserSession.signOutUser();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças no TeamProvider para obter a lista de turmas
    final teamProvider = context.watch<TeamProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // Usamos SingleChildScrollView para evitar overflow
          child: Column(
            children: [
              HomeHeader(onLogout: () => _logout(context)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/students'),
                      child: HomeMenuButton(icon: Icons.school, label: 'Alunos'),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/van'),
                      child: HomeMenuButton(icon: Icons.map, label: 'Van'),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/add-school'),
                      child: HomeMenuButton(icon: Icons.map, label: 'Escola'),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Próximas rotas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              // Constrói a lista de rotas
              if (teamProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (teamProvider.teams.isEmpty)
                const Center(child: Text('Nenhuma turma encontrada.'))
              else
              // Cria um card de rota para cada turma
                ...teamProvider.teams.map((team) => HomeRouteCard(teamId: team.id)),
            ],
          ),
        ),
      ),
    );
  }
}
