import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../utils/user_session.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  String? _userName;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = await UserSession.getUser();
    // Garante que o widget ainda está na tela antes de atualizar o estado
    if (mounted) {
      setState(() {
        _userName = user?.name;
        _isLoadingUser = false;
      });
    }
  }

  // Widget auxiliar para os cards de "Confirmados" e "Ausentes"
  Widget _buildSummaryCard(String title, int count, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.white, // Fundo branco sólido
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Sombra sutil
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)), // Borda colorida
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: AppPalette.neutral600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para cada item da lista de alunos
  Widget _buildStudentTile({
    required int index,
    required String name,
    required String address,
    required bool isConfirmed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            (index).toString(), // O index já vem como 1, 2, 3...
            style: const TextStyle(fontSize: 20, color: AppPalette.neutral800, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppPalette.neutral200,
                  backgroundImage: const AssetImage('assets/retratoCrianca.webp')
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                const SizedBox(height: 2),
                Text(address, style: const TextStyle(fontWeight: FontWeight.w400, color: AppPalette.neutral600, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SvgPicture.asset(
            isConfirmed ? 'assets/icons/check.svg' : 'assets/icons/cross.svg',
            width: 21,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: AppPalette.primary800,
      foregroundColor: AppPalette.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );

    return Scaffold(
      backgroundColor: AppPalette.neutral100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppPalette.primary900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho com nome dinâmico
            Center(
              child: _isLoadingUser
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                'Olá, ${_userName ?? 'Motorista'}!',
                style: const TextStyle(fontSize: 18, color: AppPalette.neutral600),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Rota da manhã',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppPalette.primary900),
              ),
            ),
            const SizedBox(height: 24),

            // Card do Mapa e Botão
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: Column(
                children: [
                  Image.asset(
                    'assets/rota_gps.png',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: buttonStyle,
                        child: const Text('Iniciar rota'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Seção da Lista de Confirmação
            const Text(
              'Lista de confirmação',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPalette.primary900),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Confirmados', 12, AppPalette.green500)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Ausentes', 3, AppPalette.red500)),
              ],
            ),
            const SizedBox(height: 24),

            // Lista de Alunos com o novo layout
            _buildStudentTile(index: 1, name: 'Estella Mello', address: 'Rua 15 de setembro, 345', isConfirmed: true),
            _buildStudentTile(index: 2, name: 'João Pereira', address: 'Rua das Flores, 123', isConfirmed: false),
            _buildStudentTile(index: 3, name: 'Ana Clara', address: 'Avenida Brasil, 789', isConfirmed: true),
            _buildStudentTile(index: 4, name: 'Ana Clara', address: 'Avenida Brasil, 789', isConfirmed: true),
            _buildStudentTile(index: 5, name: 'Ana Clara', address: 'Avenida Brasil, 789', isConfirmed: true),
            _buildStudentTile(index: 6, name: 'Ana Clara', address: 'Avenida Brasil, 789', isConfirmed: true),
            _buildStudentTile(index: 7, name: 'Ana Clara', address: 'Avenida Brasil, 789', isConfirmed: true),
            _buildStudentTile(index: 8, name: 'Ana Clara', address: 'Avenida Brasil, 789', isConfirmed: true),
            _buildStudentTile(index: 9, name: 'Ana Clara', address: 'Avenida Brasil, 789', isConfirmed: true),
            _buildStudentTile(index: 10, name: 'Ana Clara', address: 'Avenida Brasil, 789', isConfirmed: true),
          ],
        ),
      ),
    );
  }
}

