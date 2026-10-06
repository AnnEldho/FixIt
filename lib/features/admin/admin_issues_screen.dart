import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/issue_model.dart';
import '../../data/repositories/issue_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import '../issues/screens/issue_detail_screen.dart';
import '../issues/widgets/issue_card.dart';

/// Admin-only: all reports from all citizens with a status filter.
/// Access is also enforced by Firestore security rules (see firestore.rules).
class AdminIssuesScreen extends StatefulWidget {
  const AdminIssuesScreen({super.key});

  @override
  State<AdminIssuesScreen> createState() => _AdminIssuesScreenState();
}

class _AdminIssuesScreenState extends State<AdminIssuesScreen> {
  static const _all = 'All';

  final _stream = IssueRepository().watchAllIssues();
  String _filter = _all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: StreamBuilder<List<IssueModel>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorView(
              message: 'Unable to load reports. Make sure your account has the admin role.',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data!;
          final shown = _filter == _all
              ? all
              : all.where((i) => i.status == _filter).toList();

          return Column(
            children: [
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  children: [
                    for (final f in [_all, ...IssueStatus.all])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            f == _all
                                ? 'All (${all.length})'
                                : '$f (${all.where((i) => i.status == f).length})',
                          ),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? const EmptyState(
                        title: 'Nothing here',
                        message: 'No reports match this filter.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: shown.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final issue = shown[index];
                          return IssueCard(
                            issue: issue,
                            showReporter: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => IssueDetailScreen(
                                  issueId: issue.id,
                                  isAdmin: true,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
