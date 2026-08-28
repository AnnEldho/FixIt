import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const FixItApp());
}

class FixItApp extends StatelessWidget {
  const FixItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'FixIt',

      theme: AppTheme.darkTheme,

      home: const LoginScreen(),
    );
  }
}