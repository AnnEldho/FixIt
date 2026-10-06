import 'package:flutter/material.dart';

/// Full-width button that swaps its label for a spinner while [isLoading].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.trailingIcon = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  /// Place the icon after the label (e.g. an arrow) instead of before it.
  final bool trailingIcon;

  @override
  Widget build(BuildContext context) {
    final iconWidget = icon == null ? null : Icon(icon, size: 20);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconWidget != null && !trailingIcon) ...[
                    iconWidget,
                    const SizedBox(width: 10),
                  ],
                  Text(label),
                  if (iconWidget != null && trailingIcon) ...[
                    const SizedBox(width: 10),
                    iconWidget,
                  ],
                ],
              ),
      ),
    );
  }
}
