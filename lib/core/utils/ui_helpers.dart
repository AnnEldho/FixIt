import 'package:flutter/material.dart';

/// Shows a floating snackbar styled with the app theme.
class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    if (!context.mounted) return;
    final scheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? scheme.error : scheme.primary,
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, isError: false);
}
