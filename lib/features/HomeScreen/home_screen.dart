import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabeeby_app/features/HomeScreen/widgets/home_screen_body.dart';

import 'manager/home_screen_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeScreenProvider(),
      child: Consumer<HomeScreenProvider>(
        builder: (context, provider, _) =>
            HomeScreenBody(provider: provider),
      ),
    );
  }
}




