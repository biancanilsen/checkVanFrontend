import 'package:flutter/material.dart';

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
      // 'Turmas' (mapeado de 'Alunos' no prompt)
        Navigator.pushNamed(context, '/students');
        break;
      case 2:
      // 'Mensagens'
        Navigator.pushNamed(context, '/van');
        break;
      case 3:
      // 'Perfil'
        Navigator.pushNamed(context, '/my_profile');
        break;
    }
  }

  // --- Funções Antigas Removidas (initState, _logout) ---

  @override
  Widget build(BuildContext context) {
    // --- Lógica Antiga Removida (teamProvider) ---

    // Nova Scaffold com o design da Imagem 2
    return Scaffold(
      backgroundColor: Colors.grey[50], // Fundo cinza claro do novo design
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
        currentIndex: _selectedIndex, // Sempre 0 (Rotas) nesta tela
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Para mostrar todos os labels
        selectedItemColor: const Color(0xFF0D47A1), // Azul escuro do design
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
              _buildNextRouteCard(),

              // 4. Título "Rotas programadas"
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Rotas programadas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // 5. Lista Horizontal Mocado "Rotas programadas"
              _buildScheduledRoutesList(),
              const SizedBox(height: 20), // Espaçamento no final
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets de Apoio para o Novo Design ---

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
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
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
                        color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: Colors.grey[800], size: 28),
            onPressed: () {
              // Ação ao clicar no sino
            },
          ),
        ],
      ),
    );
  }

  /// Constrói o Card Principal "Próxima Rota"
  Widget _buildNextRouteCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 1, // Sombra sutil
        shadowColor: Colors.black.withOpacity(0.1),
        clipBehavior: Clip.antiAlias, // Garante que a imagem respeite a borda
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: 265,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/rota.png'),
              fit: BoxFit.cover,
              opacity: 0.98,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRouteInfoColumn('Alunos', '12', boldValue: true),
                    _buildRouteInfoColumn(
                      'Rota da manhã',
                      'Início',
                      icon: Icons.wb_sunny_outlined,
                      isChip: true,
                      chipLabel: 'Em 5 min',
                      chipBgColor: Colors.orange.shade100,
                      chipTextColor: Colors.orange.shade800,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Ação de "Iniciar rota"
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1), // Azul escuro
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Iniciar rota',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói a lista horizontal de "Rotas programadas"
  Widget _buildScheduledRoutesList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Padding para o primeiro item não colar na borda
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Row(
        children: [
          // Card Mocado 1
          _buildScheduledCard(
            routeName: 'Rota da tarde',
            studentCount: '14',
            startTime: 'Às 11h',
            icon: Icons.brightness_6_outlined, // Ícone da imagem (parece um download/pôr do sol)
            chipBgColor: Colors.blue.shade100,
            chipTextColor: Colors.blue.shade800,
          ),
          const SizedBox(width: 12),
          // Card Mocado 2 (para exemplo de scroll)
          _buildScheduledCard(
            routeName: 'Rota da noite',
            studentCount: '9',
            startTime: 'Às 18h',
            icon: Icons.dark_mode_outlined,
            chipBgColor: Colors.purple.shade100,
            chipTextColor: Colors.purple.shade800,
          ),
        ],
      ),
    );
  }

  /// Constrói um card individual de "Rota Programada"
  Widget _buildScheduledCard({
    required String routeName,
    required String studentCount,
    required String startTime,
    required IconData icon,
    required Color chipBgColor,
    required Color chipTextColor,
  }) {
    return SizedBox(
      // Define a largura dos cards na lista horizontal
      width: MediaQuery.of(context).size.width * 0.75,
      child: Card(
        elevation: 0,
        color: Colors.grey[200], // Fundo cinza claro do card desabilitado
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    routeName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRouteInfoColumn('Alunos', studentCount, boldValue: true),
                  _buildRouteInfoColumn(
                    'Início',
                    '',
                    isChip: true,
                    chipLabel: startTime,
                    chipBgColor: chipBgColor,
                    chipTextColor: chipTextColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: null, // Botão desabilitado
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.grey[350], // Fundo cinza do botão
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Iniciar rota',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget helper para as colunas de informação (Alunos, Início)
  Widget _buildRouteInfoColumn(
      String label,
      String value, {
        bool boldValue = false,
        IconData? icon,
        bool isChip = false,
        String chipLabel = '',
        Color? chipBgColor,
        Color? chipTextColor,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
            ],
            // O label 'Início' é o 'value' neste caso
            Text(
              isChip ? value : label,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (isChip)
        // Se for chip (Ex: "Em 5 min")
          Chip(
            label: Text(chipLabel, style: TextStyle(color: chipTextColor, fontWeight: FontWeight.w600)),
            backgroundColor: chipBgColor,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
            side: BorderSide.none,
          )
        else
        // Se for texto normal (Ex: "12" alunos)
          Text(
            value,
            style: TextStyle(
              fontSize: boldValue ? 24 : 16,
              fontWeight: boldValue ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
      ],
    );
  }
}