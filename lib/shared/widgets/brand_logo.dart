import 'package:flutter/material.dart';

/// The green location-pin tile used on auth screens and app bars.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 78});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        Icons.location_on_rounded,
        size: size * 0.56,
        color: scheme.onPrimary,
      ),
    );
  }
}

/// "FIX" in white + "IT" in brand green.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.large = true});

  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = large ? theme.textTheme.headlineLarge : theme.textTheme.titleLarge;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: 'FIX', style: base),
          TextSpan(
            text: 'IT',
            style: base?.copyWith(color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
