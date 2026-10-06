import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../data/models/issue_model.dart';
import 'status_badge.dart';

class IssueCard extends StatelessWidget {
  const IssueCard({
    super.key,
    required this.issue,
    required this.onTap,
    this.showReporter = false,
  });

  final IssueModel issue;
  final VoidCallback onTap;

  /// Admin lists show who filed the report.
  final bool showReporter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(issue.title, style: theme.textTheme.titleMedium),
                  ),
                  const SizedBox(width: 10),
                  StatusBadge(status: issue.status),
                ],
              ),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.category_outlined, text: issue.category, color: primary),
              const SizedBox(height: 7),
              _InfoRow(
                icon: Icons.location_on_outlined,
                text: issue.location,
                color: primary,
                maxLines: 2,
              ),
              if (showReporter && issue.reportedByEmail.isNotEmpty) ...[
                const SizedBox(height: 7),
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  text: issue.reportedByEmail,
                  color: primary,
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    DateFormatter.timeAgo(issue.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    'View details',
                    style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.color,
    this.maxLines = 1,
  });

  final IconData icon;
  final String text;
  final Color color;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
