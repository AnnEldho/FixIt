import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/issue_model.dart';
import '../../../data/repositories/issue_repository.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../widgets/status_badge.dart';
import '../widgets/status_timeline.dart';

/// Live view of a single issue. When [isAdmin] is true the status can be
/// changed (Firestore rules also enforce this server-side).
class IssueDetailScreen extends StatelessWidget {
  const IssueDetailScreen({
    super.key,
    required this.issueId,
    this.isAdmin = false,
  });

  final String issueId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Details')),
      body: StreamBuilder<IssueModel?>(
        stream: IssueRepository().watchIssue(issueId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorView(message: 'Unable to load this report.');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final issue = snapshot.data;
          if (issue == null) {
            return const EmptyState(
              title: 'Report not found',
              message: 'This report may have been removed.',
            );
          }

          return _DetailBody(issue: issue, isAdmin: isAdmin);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.issue, required this.isAdmin});

  final IssueModel issue;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(status: issue.status),
          const SizedBox(height: 20),
          Text(issue.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Reported ${DateFormatter.date(issue.createdAt)}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          _Field(label: 'Category', value: issue.category),
          _Field(label: 'Location', value: issue.location, icon: Icons.location_on_outlined),
          _Field(label: 'Description', value: issue.description),
          if (isAdmin) _Field(label: 'Reported by', value: issue.reportedByEmail),
          if (isAdmin) ...[
            const SizedBox(height: 4),
            _AdminStatusControl(issue: issue),
            const SizedBox(height: 30),
          ],
          StatusTimeline(status: issue.status),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 7),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
              ],
              Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminStatusControl extends StatefulWidget {
  const _AdminStatusControl({required this.issue});

  final IssueModel issue;

  @override
  State<_AdminStatusControl> createState() => _AdminStatusControlState();
}

class _AdminStatusControlState extends State<_AdminStatusControl> {
  final _issues = IssueRepository();
  bool _saving = false;

  Future<void> _change(String status) async {
    if (status == widget.issue.status) return;

    setState(() => _saving = true);
    try {
      await _issues.updateStatus(widget.issue.id, status);
      if (mounted) AppSnackBar.success(context, 'Status updated to $status.');
    } on AppException catch (e) {
      if (mounted) AppSnackBar.show(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.admin_panel_settings_outlined,
                  color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('Update status', style: theme.textTheme.titleMedium),
              const Spacer(),
              if (_saving)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in IssueStatus.all)
                ChoiceChip(
                  label: Text(status),
                  selected: widget.issue.status == status,
                  onSelected: _saving ? null : (_) => _change(status),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
