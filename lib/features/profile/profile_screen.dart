import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// "Profile" tab: account details, admin entry point and logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user, required this.fallbackEmail});

  final UserModel? user;
  final String fallbackEmail;

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // AuthGate swaps to the login screen automatically.
      await AuthRepository().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = (user?.name.isNotEmpty ?? false) ? user!.name : 'FixIt user';
    final email = (user?.email.isNotEmpty ?? false) ? user!.email : fallbackEmail;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: CircleAvatar(
                radius: 42,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  user?.initial ?? name[0].toUpperCase(),
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text(name, style: theme.textTheme.titleLarge)),
            const SizedBox(height: 4),
            Center(child: Text(email, style: theme.textTheme.bodyMedium)),
            if (user?.isAdmin ?? false) ...[
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ADMIN',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            _InfoTile(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: (user?.phone.isNotEmpty ?? false) ? user!.phone : '—',
            ),
            const SizedBox(height: 12),
            _InfoTile(
              icon: Icons.calendar_today_outlined,
              label: 'Member since',
              value: DateFormatter.date(user?.createdAt),
            ),
            const SizedBox(height: 30),
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('LOGOUT'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 3),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
