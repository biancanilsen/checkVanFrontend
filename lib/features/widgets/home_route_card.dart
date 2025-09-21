import 'package:flutter/material.dart';

class HomeRouteCard extends StatelessWidget {
  const HomeRouteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias, // Garante que o InkWell respeite as bordas
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // InkWell torna o Card clicável e adiciona o efeito de toque
        child: InkWell(
          onTap: () {
            // Navega para a página de rota ao ser clicado
            Navigator.pushNamed(context, '/route');
          },
          child: Column(
            children: [
              Image.asset(
                'assets/rota_gps.png',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('05/02/2024'), // Você pode tornar esta data dinâmica
              ),
            ],
          ),
        ),
      ),
    );
  }
}
