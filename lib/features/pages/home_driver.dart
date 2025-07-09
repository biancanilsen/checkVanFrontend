import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/home_provider.dart';
import '../../utils/user_session.dart';
import '../forms/home_form.dart';
import '../widgets/home_header.dart';

class HomeDriver extends StatelessWidget {
  const HomeDriver({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: const _HomeDriverView(),
    );
  }
}

class _HomeDriverView extends StatelessWidget {
  const _HomeDriverView();

  void _logout(BuildContext context) async {
    await UserSession.signOutUser();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  Future<String> _loadNameUser() async {
    final user = await UserSession.getUser();
    return user?.name?.isNotEmpty == true ? user!.name : "Usuário";
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    final user = UserSession.getUser();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(onLogout: () => _logout(context)),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/students');
                    },
                    child: HomeMenuButton(icon: Icons.school, label: 'Alunos'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/trips');
                    },
                    child: HomeMenuButton(icon: Icons.map, label: 'Viagens'),
                  ),
                  HomeMenuButton(icon: Icons.alt_route, label: 'Rotas'),
                ],
              ),
            ),

            // Próxima Rota
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Próxima rota', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            HomeRouteCard(),

            // Boletos
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Boletos em aberto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Ver tudo', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.boletos.length,
                itemBuilder: (_, index) {
                  final item = provider.boletos[index];
                  return Card(
                    child: ListTile(title: Text(item)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
