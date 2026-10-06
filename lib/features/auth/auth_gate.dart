import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/auth_repository.dart';
import '../home/home_shell.dart';
import 'screens/login_screen.dart';

/// Decides the first screen from the Firebase session, so users stay logged
/// in after closing the app and are sent back to login after signing out.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthRepository().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return HomeShell(key: ValueKey(snapshot.data!.uid));
        }

        return const LoginScreen();
      },
    );
  }
}
