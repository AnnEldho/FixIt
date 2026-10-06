import 'package:flutter/material.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

/// Sends a Firebase password-reset email, then shows a confirmation state.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  /// Pre-filled from the login screen if the user already typed it.
  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(text: widget.initialEmail);
  final _auth = AuthRepository();

  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _auth.sendPasswordReset(_emailController.text);
      if (!mounted) return;
      setState(() => _sent = true);
    } on AppException catch (e) {
      if (mounted) AppSnackBar.show(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _sent ? _buildSent(context) : _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.lock_reset_rounded,
                size: 34, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 22),
          Text('Forgot your password?', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Enter the email you registered with and we will send you a link to choose a new password.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 30),
          AppTextField(
            label: 'Email address',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            controller: _emailController,
            enabled: !_isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email,
            onSubmitted: _send,
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'SEND RESET LINK',
            icon: Icons.send_rounded,
            isLoading: _isLoading,
            onPressed: _send,
          ),
        ],
      ),
    );
  }

  Widget _buildSent(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Icon(Icons.mark_email_read_outlined,
              size: 44, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 24),
        Text('Check your inbox', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 10),
        Text(
          'If an account exists for\n${_emailController.text.trim()}\nyou will receive a reset link shortly.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Text(
          'Can’t find it? Check your spam or junk folder.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'BACK TO LOGIN',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _isLoading ? null : _send,
          child: const Text('Resend email'),
        ),
      ],
    );
  }
}