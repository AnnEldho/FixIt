import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Shown when a Firestore stream fails (e.g. permission denied, offline).
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.message = 'Something went wrong.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40, color: AppTheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
