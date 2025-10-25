import 'package:flutter/material.dart';

import '../../forms/my_profile_form.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu perfil'),
      ),
      body: MyProfileForm(),
    );
  }
}
