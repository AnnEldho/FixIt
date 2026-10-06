import 'package:flutter/material.dart';

import '../../../data/models/issue_model.dart';
import '../../../data/repositories/issue_repository.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../widgets/issue_card.dart';
import 'issue_detail_screen.dart';

/// "Reports" tab: every issue the signed-in user has filed.
class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: StreamBuilder<List<IssueModel>>(
        stream: IssueRepository().watchUserIssues(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorView(message: 'Unable to load your reports.');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!;
          if (reports.isEmpty) {
            return const EmptyState(
              title: 'No reports yet',
              message: 'Issues you report will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final issue = reports[index];
              return IssueCard(
                issue: issue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IssueDetailScreen(issueId: issue.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
