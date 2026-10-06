import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../admin/admin_shell.dart';
import '../dashboard/dashboard_screen.dart';
import '../issues/screens/my_reports_screen.dart';
import '../profile/profile_screen.dart';

/// Signed-in container: bottom navigation + the three main tabs.
/// Tabs are kept alive with an [IndexedStack] so scroll position is preserved.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  late final Stream<UserModel?> _profile =
      UserRepository().watchUser(_currentUser.uid);

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _profile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user != null && user.isAdmin) {
          return AdminShell(user: user);
        }

        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              DashboardScreen(
                user: user,
                userId: _currentUser.uid,
                onViewAll: () => setState(() => _index = 1),
              ),
              MyReportsScreen(userId: _currentUser.uid),
              ProfileScreen(
                user: user,
                fallbackEmail: _currentUser.email ?? '',
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment_rounded),
                label: 'Reports',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
