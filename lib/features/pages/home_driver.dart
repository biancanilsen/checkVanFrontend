import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

import '../widgets/ScheduledRoutes/scheduled_routes_list.dart';
import '../widgets/nextRoute/next_route_card.dart';

class HomeDriver extends StatelessWidget {
  const HomeDriver({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeDriverView();
  }
}

class _HomeDriverView extends StatefulWidget {
  const _HomeDriverView();

  @override
  State<_HomeDriverView> createState() => _HomeDriverViewState();
}

class _HomeDriverViewState extends State<_HomeDriverView> {
  // Controla o item selecionado no BottomNavBar
  int _selectedIndex = 0;

  // Gerencia a troca de telas pelo BottomNavBar
  void _onItemTapped(int index) {
    // Evita recarregar a mesma tela
    if (index == _selectedIndex) return;

    // Navega para a rota correspondente
    // A troca de estado (setState) será tratada pela navegação
    // se as outras telas substituírem a Home.
    // Se elas forem empilhadas (push), atualizamos o índice.

    // setState(() {
    //   _selectedIndex = index;
    // });

    switch (index) {
      case 0:
        // 'Rotas' - Já estamos aqui
        break;
      case 1:
        Navigator.pushNamed(context, '/students');
        break;
      case 2:
        Navigator.pushNamed(context, '/van');
        break;
      case 3:
        Navigator.pushNamed(context, '/my_profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.route_outlined),
            activeIcon: Icon(Icons.route),
            label: 'Rotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Turmas', // Label da Imagem 2
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Mensagens', // Label da Imagem 2
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil', // Label da Imagem 2
          ),
        ],
        currentIndex: _selectedIndex,
        // Sempre 0 (Rotas) nesta tela
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        // Para mostrar todos os labels
        selectedItemColor: const Color(0xFF0D47A1),
        // Azul escuro do design
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Novo Header com Perfil e Notificações
              _buildHeader(),

              // 2. Título "Próxima Rota"
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Próxima Rota',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // 3. Card Mocado "Próxima Rota"
              const NextRouteCard(),

              // 4. Título "Rotas programadas"
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Rotas programadas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // 5. Lista Horizontal Mocado "Rotas programadas"
              const ScheduledRoutesList(),
              const SizedBox(height: 20), // Espaçamento no final
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o Header (Foto, Nome, Sino de Notificação)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                // Imagem mocada
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=12',
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bom dia,',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const Text(
                    'Renato Siqueira', // Nome mocado
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none_outlined,
              color: Colors.grey[800],
              size: 28,
            ),
            onPressed: () {
              // Ação ao clicar no sino
            },
          ),
        ],
      ),
    );
  }
}
