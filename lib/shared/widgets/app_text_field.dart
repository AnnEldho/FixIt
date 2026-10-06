import 'package:flutter/material.dart';

/// Label above a themed [TextFormField]. Pass [obscure] for password fields
/// and a visibility toggle is added automatically.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.obscure = false,
    this.enabled = true,
    this.maxLines = 1,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool obscure;
  final bool enabled;
  final int maxLines;
  final VoidCallback? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _hidden,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          onFieldSubmitted: (_) => widget.onSubmitted?.call(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.maxLines > 1
                ? Padding(
                    padding: EdgeInsets.only(bottom: 18.0 * (widget.maxLines - 1)),
                    child: Icon(widget.icon),
                  )
                : Icon(widget.icon),
            suffixIcon: widget.obscure
                ? IconButton(
                    onPressed: widget.enabled
                        ? () => setState(() => _hidden = !_hidden)
                        : null,
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
