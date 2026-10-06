import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/issue_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/issue_repository.dart';
import '../../shared/widgets/brand_logo.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stat_card.dart';
import '../issues/screens/issue_detail_screen.dart';
import '../issues/widgets/issue_card.dart';

/// Admin home tab: totals, per-category breakdown and the latest reports.
class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({super.key, required this.user, required this.onViewAll});

  final UserModel user;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      body: StreamBuilder<List<IssueModel>>(
        stream: IssueRepository().watchAllIssues(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorView(message: 'Unable to load reports.');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final issues = snapshot.data!;
          int count(String s) => issues.where((i) => i.status == s).length;

          final byCategory = <String, int>{};
          for (final i in issues) {
            byCategory[i.category] = (byCategory[i.category] ?? 0) + 1;
          }
          final categories = byCategory.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin dashboard', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text('Welcome, ${user.name.split(' ').first}.',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),
                Row(children: [
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
                      value: '${count(IssueStatus.reported)}',
                      label: 'New',
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.sync_rounded,
                      value: '${count(IssueStatus.inProgress)}',
                      label: 'In Progress',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.check_circle_outline_rounded,
                      value: '${count(IssueStatus.resolved)}',
                      label: 'Resolved',
                    ),
                  ),
                ]),
                const SizedBox(height: 30),
                Text('By category', style: theme.textTheme.titleLarge),
                const SizedBox(height: 14),
                if (categories.isEmpty)
                  const EmptyState(
                    compact: true,
                    title: 'No data yet',
                    message: 'Category totals appear once reports come in.',
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      children: [
                        for (final e in categories)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(e.key,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium),
                                ),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: e.value / issues.length,
                                      minHeight: 8,
                                      backgroundColor: AppTheme.surfaceLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text('${e.value}', style: theme.textTheme.bodyLarge),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),
                SectionHeader(
                  title: 'Latest reports',
                  actionLabel: 'View all',
                  onAction: onViewAll,
                ),
                const SizedBox(height: 8),
                for (final issue in issues.take(3)) ...[
                  IssueCard(
                    issue: issue,
                    showReporter: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            IssueDetailScreen(issueId: issue.id, isAdmin: true),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
