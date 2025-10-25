import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../model/route_model.dart';
import '../../provider/route_provider.dart';
import '../../utils/user_session.dart';
import '../widgets/route/route_page_header.dart';
import '../widgets/route/start_route_map_card.dart';
import '../widgets/route/studentAccordion/student_accordion.dart';
import '../widgets/route/student_tile.dart';
import '../widgets/route/summary_card.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  String? _userName;
  bool _isLoadingUser = true;
  RouteData? routeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is RouteData) {
      routeData = args;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = await UserSession.getUser();
    if (mounted) {
      setState(() {
        _userName = user?.name;
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _startRoute() async {
    if (mounted) {
      Navigator.pushNamed(
        context,
        '/active-route',
        arguments: routeData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // A lógica de 'routeProvider' e cálculos permanece a mesma
    final routeProvider = context.watch<RouteProvider>();

    if (routeData == null) {
      return const Scaffold(
        body: Center(
          child: Text('Dados da rota não encontrados'),
        ),
      );
    }

    final students = routeData!.students;
    final confirmedStudents =
    students.where((s) => s.isConfirmed == true).toList();
    final pendingStudents =
    students.where((s) => s.isConfirmed == null).toList();
    final absentStudents =
    students.where((s) => s.isConfirmed == false).toList();

    return Scaffold(
      backgroundColor: AppPalette.appBackground, // Fundo do tema
      appBar: AppBar(
        title: const Text('Rota ida manhã'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppPalette.primary900,
      ),
      body: SingleChildScrollView(
        // Padding foi movido para horizontal: 16 para os cards
        // ocuparem a largura total
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StartRouteMapCard(
              onStartRoutePressed: _startRoute,
            ),
            const SizedBox(height: 32),

            // Título da Seção
            const Padding(
              // Adiciona padding horizontal de volta para o título
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Lista de presença',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.primary900,
                ),
              ),
            ),
            const SizedBox(height: 16),

            StudentAccordion(
              title: 'Confirmados',
              count: confirmedStudents.length,
              countColor: AppPalette.green500,
              students: confirmedStudents,
              itemIcon: Icons.check_circle_outline, // Ícone de exemplo
              itemIconColor: AppPalette.green500,
            ),
            StudentAccordion(
              title: 'Pendentes',
              count: pendingStudents.length,
              countColor: AppPalette.orange700,
              students: pendingStudents,
              itemIcon: Icons.access_time_rounded, // Ícone de relógio da imagem
              itemIconColor: AppPalette.orange700,
              initiallyExpanded: true, // Deixa aberto por padrão
            ),
            StudentAccordion(
              title: 'Ausentes',
              count: absentStudents.length,
              countColor: AppPalette.red500,
              students: absentStudents,
              itemIcon: Icons.cancel_outlined, // Ícone de exemplo
              itemIconColor: AppPalette.red500,
            ),
            const SizedBox(height: 24), // Espaçamento no final
          ],
        ),
      ),
    );
  }
}