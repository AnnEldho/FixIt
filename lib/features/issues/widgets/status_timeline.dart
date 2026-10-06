import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.status});

  final String status;

  static const _steps = [
    (IssueStatus.reported, Icons.assignment_outlined),
    (IssueStatus.inProgress, Icons.sync_rounded),
    (IssueStatus.resolved, Icons.check_circle_outline_rounded),
  ];

  int get _currentStep {
    final index = IssueStatus.all.indexOf(status);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.35);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress', style: theme.textTheme.titleMedium),
        const SizedBox(height: 18),
        for (var i = 0; i < _steps.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(_steps[i].$2, size: 22, color: i <= _currentStep ? primary : muted),
                  if (i < _steps.length - 1)
                    Container(
                      width: 2,
                      height: 35,
                      color: i < _currentStep ? primary : theme.dividerColor,
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  _steps[i].$1,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: i <= _currentStep
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: i <= _currentStep ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
