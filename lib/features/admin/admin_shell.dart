import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';
import '../profile/profile_screen.dart';
import 'admin_issues_screen.dart';
import 'admin_overview_screen.dart';

/// Signed-in container for admins: Overview, all Reports, Profile.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.user});

  final UserModel user;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          AdminOverviewScreen(
            user: widget.user,
            onViewAll: () => setState(() => _index = 1),
          ),
          const AdminIssuesScreen(),
          ProfileScreen(user: widget.user, fallbackEmail: widget.user.email),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Overview',
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
  }
}
