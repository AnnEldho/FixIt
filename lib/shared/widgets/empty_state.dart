import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.assignment_outlined,
    this.compact = false,
  });

  final String title;
  final String message;
  final IconData icon;

  /// Compact = bordered card for inline use; otherwise centred full page.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 58 : 76,
          height: compact ? 58 : 76,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(compact ? 18 : 22),
          ),
          child: Icon(
            icon,
            size: compact ? 28 : 36,
            color: compact ? AppTheme.textSecondary : theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: compact ? theme.textTheme.titleMedium : theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
      ],
    );

    if (compact) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.divider),
        ),
        child: content,
      );
    }

    return Center(
      child: Padding(padding: const EdgeInsets.all(30), child: content),
    );
  }
}
