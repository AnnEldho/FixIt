import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/app_theme.dart';
import 'report_issue_screen.dart';
import 'my_reports_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    final String userName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim().split(' ').first
        : 'there';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: theme.colorScheme.onPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'FIX',
                    style: theme.textTheme.titleLarge,
                  ),
                  TextSpan(
                    text: 'IT',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(
              Icons.logout_rounded,
            ),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ============================================
      // DASHBOARD BODY
      // ============================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================================
              // GREETING
              // ======================================

              Text(
                'Hello, $userName 👋',
                style: theme.textTheme.headlineMedium,
              ),

              const SizedBox(height: 6),

              Text(
                'Let’s make your community better.',
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              // ======================================
              // REPORT ISSUE CARD
              // ======================================

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportIssueScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.add_location_alt_rounded,
                          size: 30,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Report an Issue',
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(
                                color:
                                theme.colorScheme.onPrimary,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'See something that needs fixing?',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: theme.colorScheme.onPrimary
                                    .withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Icon(
                        Icons.arrow_forward_rounded,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ======================================
              // ACTIVITY TITLE
              // ======================================

              Text(
                'Your activity',
                style: theme.textTheme.titleLarge,
              ),

              const SizedBox(height: 14),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('issues')
                    .where(
                  'reportedBy',
                  isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 170,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Unable to load activity.',
                      style: theme.textTheme.bodyMedium,
                    );
                  }

                  final reports = snapshot.data?.docs ?? [];

                  int totalReports = reports.length;
                  int pendingReports = 0;
                  int inProgressReports = 0;
                  int resolvedReports = 0;

                  for (final report in reports) {
                    final data = report.data() as Map<String, dynamic>;

                    final status = data['status']?.toString() ?? 'Reported';

                    if (status == 'Reported') {
                      pendingReports++;
                    } else if (status == 'In Progress') {
                      inProgressReports++;
                    } else if (status == 'Resolved') {
                      resolvedReports++;
                    }
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.assignment_outlined,
                              value: totalReports.toString(),
                              label: 'Total Reports',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.pending_actions_outlined,
                              value: pendingReports.toString(),
                              label: 'Pending',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.sync_rounded,
                              value: inProgressReports.toString(),
                              label: 'In Progress',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.check_circle_outline_rounded,
                              value: resolvedReports.toString(),
                              label: 'Resolved',
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),


              const SizedBox(height: 30),

              // ======================================
              // RECENT REPORTS
              // ======================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent reports',
                    style: theme.textTheme.titleLarge,
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyReportsScreen(),
                        ),
                      );
                    },
                    child: const Text('View all'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ======================================
              // EMPTY REPORT STATE
              // ======================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppTheme.divider,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        size: 28,
                        color: AppTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'No reports yet',
                      style: theme.textTheme.titleMedium,
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Your reported issues will appear here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ======================================
              // COMMUNITY MESSAGE
              // ======================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.volunteer_activism_outlined,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Every report matters.',
                            style: theme.textTheme.titleMedium,
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Help make your surroundings safer and better.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ============================================
      // BOTTOM NAVIGATION
      // ============================================

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyReportsScreen(),
              ),
            );
          }

          if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Profile will be added next.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
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
  }

  // ============================================
  // LOGOUT DIALOG
  // ============================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await FirebaseAuth.instance.signOut();

                if (!context.mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                      (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

// ==================================================
// STAT CARD
// ==================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),

          const SizedBox(height: 14),

          Text(
            value,
            style: theme.textTheme.headlineMedium,
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}