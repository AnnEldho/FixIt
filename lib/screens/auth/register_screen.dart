import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // =========================
  // REGISTER USER
  // =========================

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Basic validation
    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage('Please fill in all fields.');
      return;
    }

    if (password.length < 6) {
      showMessage('Password must contain at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords do not match.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // =========================
      // 1. CREATE AUTH ACCOUNT
      // =========================

      final UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Unable to create user account.');
      }

      // =========================
      // 2. STORE USER DATA
      // =========================

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // =========================
      // 3. UPDATE DISPLAY NAME
      // =========================

      await user.updateDisplayName(name);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'Account created successfully!',
        isError: false,
      );

      // Go back to login screen
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'weak-password':
          message = 'Please choose a stronger password.';
          break;

        case 'operation-not-allowed':
          message = 'Email/password registration is not enabled.';
          break;

        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;

        default:
          message = 'Registration failed: ${e.code}';
      }

      showMessage(message);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'Database error: ${e.message ?? e.code}',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'Something went wrong. Please try again.',
      );
    }
  }

  // =========================
  // MESSAGE
  // =========================

  void showMessage(
      String message, {
        bool isError = true,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // BACK BUTTON
              // =========================

              IconButton(
                onPressed: isLoading
                    ? null
                    : () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                ),
              ),

              const SizedBox(height: 18),

              // =========================
              // TITLE
              // =========================

              Text(
                'Create your account',
                style: theme.textTheme.headlineMedium,
              ),

              const SizedBox(height: 8),

              Text(
                'Join FixIt and help improve your community.',
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 32),

              // =========================
              // FULL NAME
              // =========================

              Text(
                'Full name',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // EMAIL
              // =========================

              Text(
                'Email address',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // PHONE
              // =========================

              Text(
                'Phone number',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  hintText: 'Enter your phone number',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // PASSWORD
              // =========================

              Text(
                'Password',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: 'Create a password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),
                  suffixIcon: IconButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // CONFIRM PASSWORD
              // =========================

              Text(
                'Confirm password',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                enabled: !isLoading,
                onSubmitted: (_) {
                  if (!isLoading) {
                    registerUser();
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Re-enter your password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),
                  suffixIcon: IconButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      setState(() {
                        obscureConfirmPassword =
                        !obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // CREATE ACCOUNT BUTTON
              // =========================

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : registerUser,
                  child: isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('CREATE ACCOUNT'),
                      SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // =========================
              // LOGIN LINK
              // =========================

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Already have an account?',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                        Navigator.pop(context);
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'FIXIT • Community Issue Resolution',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}