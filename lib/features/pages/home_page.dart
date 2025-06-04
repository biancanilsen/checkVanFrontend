// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import '../../utils/user_session.dart';
import '../forms/my_profile_form.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_tab_bar.dart';
import 'home_guardian.dart';
import 'home_screen.dart';

List<String> titles = <String>['Cloud', 'Home', 'Perfil'];

class HomePage extends StatelessWidget {
  /// Agora você pode controlar de fora qual aba abre primeiro
  final int initialIndex;
  const HomePage({
    super.key,
    this.initialIndex = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final oddColor = colorScheme.primary.withOpacity(0.05);
    final evenColor = colorScheme.primary.withOpacity(0.15);

    return DefaultTabController(
      length: titles.length,
      initialIndex: initialIndex,
      child: Scaffold(
        // appBar: const CustomAppBar(),
        body: TabBarView(
          children: <Widget>[
            _buildListView(titles[0], oddColor, evenColor),
            FutureBuilder(
              future: UserSession.getUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Erro ao carregar usuário'));
                } else {
                  final user = snapshot.data!;
                  final role = user.role?.toUpperCase();

                  if (role == 'DRIVER') {
                    return const HomeScreen();
                  } else if (role == 'GUARDIAN') {
                    return const HomeGuardian(); // substitua pela sua tela
                  } else {
                    return const Center(child: Text('Tipo de usuário desconhecido'));
                  }
                }
              },
            ),
            // const HomeScreen(),
            const MyProfileForm(),
          ],
        ),
        bottomNavigationBar: CustomBottomTabBar(titles: titles),
      ),
    );
  }

  Widget _buildListView(String title, Color odd, Color even) {
    return ListView.builder(
      itemCount: 25,
      itemBuilder: (ctx, i) => ListTile(
        tileColor: i.isOdd ? odd : even,
        title: Text('$title $i'),
      ),
    );
  }
}
