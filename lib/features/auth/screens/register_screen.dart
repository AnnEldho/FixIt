import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _auth = AuthRepository();


  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _auth.register(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      AppSnackBar.success(context, 'Account created successfully!');
      // Registration signs the user in; drop back to the root so AuthGate
      // can show the home screen.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AppException catch (e) {
      if (mounted) AppSnackBar.show(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(height: 18),
                Text('Create your account', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Join FixIt and help improve your community.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Full name',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                  controller: _nameController,
                  enabled: !_isLoading,
                  validator: Validators.minLength(2, 'Name'),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Email address',
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Phone number',
                  hint: 'Enter your phone number',
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Password',
                  hint: 'Create a password',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  enabled: !_isLoading,
                  obscure: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Confirm password',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline,
                  controller: _confirmController,
                  enabled: !_isLoading,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.confirmPassword(
                    () => _passwordController.text,
                  ),
                  onSubmitted: _register,
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  label: 'CREATE ACCOUNT',
                  icon: Icons.arrow_forward_rounded,
                  trailingIcon: true,
                  isLoading: _isLoading,
                  onPressed: _register,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Already have an account?', style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(child: Text(AppConstants.footer, style: theme.textTheme.bodySmall)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
