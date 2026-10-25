import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/welcome/welcome_screen.dart';

class CampusBoboApp extends StatelessWidget {
  const CampusBoboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Bobo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const WelcomeScreen(),
    );
  }
}
