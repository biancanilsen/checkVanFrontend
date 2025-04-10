import 'package:flutter/material.dart';

import '../forms/my_profile_form.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_tab_bar.dart';

List<String> titles = <String>['Cloud', 'Beach', 'Perfil'];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    const int tabsCount = 3;

    return DefaultTabController(
      length: tabsCount,
      initialIndex: 1,
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: TabBarView(
          children: <Widget>[
            _buildListView(titles[0], oddItemColor, evenItemColor),
            _buildListView(titles[1], oddItemColor, evenItemColor),
            const MyProfileForm(),
          ],
        ),
        bottomNavigationBar: CustomBottomTabBar(titles: titles),
      ),
    );
  }

  Widget _buildListView(String title, Color oddColor, Color evenColor) {
    return ListView.builder(
      itemCount: 25,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          tileColor: index.isOdd ? oddColor : evenColor,
          title: Text('$title $index'),
        );
      },
    );
  }
}
