import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/issue_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/issue_repository.dart';
import '../../shared/widgets/brand_logo.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stat_card.dart';
import '../issues/screens/issue_detail_screen.dart';
import '../issues/screens/report_issue_screen.dart';
import '../issues/widgets/issue_card.dart';

/// "Home" tab: greeting, quick report button, live stats and recent reports.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.user,
    required this.userId,
    required this.onViewAll,
  });

  /// Profile document (may still be `null` for a moment after sign-up).
  final UserModel? user;
  final String userId;

  /// Switches the bottom navigation to the Reports tab.
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name.trim().split(' ').first
        : 'there';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            BrandLogo(size: 38),
            SizedBox(width: 10),
            BrandWordmark(large: false),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, $firstName 👋', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text('Let’s make your community better.',
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              _ReportBanner(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
                ),
              ),
              const SizedBox(height: 30),
              StreamBuilder<List<IssueModel>>(
                stream: IssueRepository().watchUserIssues(userId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Unable to load activity.',
                        style: theme.textTheme.bodyMedium);
                  }
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 170,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _ActivitySection(
                    issues: snapshot.data!,
                    onViewAll: onViewAll,
                  );
                },
              ),
              const SizedBox(height: 30),
              const _CommunityNote(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportBanner extends StatelessWidget {
  const _ReportBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;

    return Material(
      color: theme.colorScheme.primary,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: onPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.add_location_alt_rounded, size: 30, color: onPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Report an Issue',
                        style: theme.textTheme.titleLarge?.copyWith(color: onPrimary)),
                    const SizedBox(height: 5),
                    Text(
                      'See something that needs fixing?',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: onPrimary.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.issues, required this.onViewAll});

  final List<IssueModel> issues;
  final VoidCallback onViewAll;

  int _count(String status) => issues.where((i) => i.status == status).length;

  @override
  Widget build(BuildContext context) {
    final recent = issues.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your activity', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.assignment_outlined,
                value: '${issues.length}',
                label: 'Total Reports',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.pending_actions_outlined,
                value: '${_count(IssueStatus.reported)}',
                label: 'Pending',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.sync_rounded,
                value: '${_count(IssueStatus.inProgress)}',
                label: 'In Progress',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.check_circle_outline_rounded,
                value: '${_count(IssueStatus.resolved)}',
                label: 'Resolved',
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        SectionHeader(
          title: 'Recent reports',
          actionLabel: 'View all',
          onAction: onViewAll,
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          const EmptyState(
            compact: true,
            title: 'No reports yet',
            message: 'Your reported issues will appear here.',
          )
        else
          for (final issue in recent) ...[
            IssueCard(
              issue: issue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IssueDetailScreen(issueId: issue.id),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _CommunityNote extends StatelessWidget {
  const _CommunityNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.volunteer_activism_outlined,
              color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Every report matters.', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Help make your surroundings safer and better.',
                    style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
