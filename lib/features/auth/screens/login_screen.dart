import 'package:flutter/material.dart';
import 'forgot_password_screen.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/brand_logo.dart';
import '../../../shared/widgets/primary_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthRepository();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _auth.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // No navigation needed: AuthGate reacts to the new session.
    } on AppException catch (e) {
      if (mounted) AppSnackBar.show(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final emailError = Validators.email(_emailController.text);
    if (emailError != null) {
      AppSnackBar.show(context, 'Enter your email address first.');
      return;
    }

    try {
      await _auth.sendPasswordReset(_emailController.text);
      if (mounted) AppSnackBar.success(context, 'Password reset email sent.');
    } on AppException catch (e) {
      if (mounted) AppSnackBar.show(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: BrandLogo()),
                const SizedBox(height: 18),
                const Center(child: BrandWordmark()),
                const SizedBox(height: 6),
                Center(
                  child: Text(AppConstants.tagline, style: theme.textTheme.bodyMedium),
                ),
                const SizedBox(height: 48),
                Text('Welcome back!', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Sign in to continue to FixIt', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 30),
                AppTextField(
                  label: 'Email address',
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 22),
                AppTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  enabled: !_isLoading,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Password is required' : null,
                  onSubmitted: _login,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'CONTINUE',
                  icon: Icons.arrow_forward_rounded,
                  trailingIcon: true,
                  isLoading: _isLoading,
                  onPressed: _login,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text('OR', style: theme.textTheme.bodySmall),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('New to FixIt?', style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                ),
                        child: const Text('Create account'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Center(child: Text(AppConstants.footer, style: theme.textTheme.bodySmall)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
