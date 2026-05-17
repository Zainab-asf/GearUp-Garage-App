import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gearup_garage/presentation/state/auth_controller.dart';
import 'package:gearup_garage/core/ui/app_scaffold.dart';
import 'package:gearup_garage/core/utils/app_snackbar.dart';
import 'package:gearup_garage/core/utils/input_validators.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/presentation/customer/customer_home.dart';
import 'package:gearup_garage/presentation/auth/customer_signup.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  int _failedAttempts = 0;
  DateTime? _blockUntil;
  bool _isBlocked = false;
  Timer? _blockTimer;

  void handleLogin() async {
    if (_isBlocked && _blockUntil != null) {
      final now = DateTime.now();
      if (now.isBefore(_blockUntil!)) {
        final remainingSeconds = _blockUntil!.difference(now).inSeconds;
        showAppSnackBar(
          context,
          'Too many failed attempts. Try again in $remainingSeconds seconds.',
          isError: true,
        );
        return;
      }
      _resetLoginAttempts();
    }

    final email = emailController.text.trim();
    final password = passwordController.text;

    final emailError = AppValidators.validateEmail(email);
    if (emailError != null) {
      showAppSnackBar(context, emailError, isError: true);
      return;
    }

    final passwordError = AppValidators.validateStrongPassword(password);
    if (passwordError != null) {
      showAppSnackBar(context, passwordError, isError: true);
      return;
    }

    final auth = context.read<AuthController>();
    final result = await auth.signInCustomer(email, password);

    if (!mounted) return;

    if (!result.ok) {
      _handleFailedLogin();
      showAppSnackBar(context, result.message ?? 'Login failed', isError: true);
      return;
    }

    _resetLoginAttempts();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MyHome()),
    );
  }

  void navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MySignup()),
    );
  }

  void _handleFailedLogin() {
    setState(() {
      _failedAttempts++;

      if (_failedAttempts >= 3) {
        _isBlocked = true;
        _blockUntil = DateTime.now().add(const Duration(seconds: 10));
        showAppSnackBar(
          context,
          'Too many failed attempts. Login blocked for 10 seconds.',
          isError: true,
        );
        _startBlockTimer();
      } else {
        final remainingAttempts = 3 - _failedAttempts;
        showAppSnackBar(
          context,
          'Login failed. $remainingAttempts attempts remaining.',
          isError: true,
        );
      }
    });
  }

  void _resetLoginAttempts() {
    _blockTimer?.cancel();
    setState(() {
      _failedAttempts = 0;
      _isBlocked = false;
      _blockUntil = null;
    });
  }

  void _startBlockTimer() {
    _blockTimer?.cancel();
    _blockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_blockUntil != null && DateTime.now().isAfter(_blockUntil!)) {
        timer.cancel();
        _resetLoginAttempts();
      } else {
        setState(() {});
      }
    });
  }

  bool _isLoginButtonEnabled() {
    if (!_isBlocked) return true;
    if (_blockUntil == null) return true;

    final now = DateTime.now();
    if (now.isAfter(_blockUntil!)) {
      _resetLoginAttempts();
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    _blockTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = context.watch<AuthController>().isLoading;

    return AppScaffold(
      appBar: AppBar(title: const Text('Customer Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back', style: theme.textTheme.displaySmall),
              const SizedBox(height: 6),
              Text(
                'Book services, manage bookings, and chat with providers.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isBlocked && _blockUntil != null) ...[
                Text(
                  'Login temporarily locked. Please wait a moment.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.error,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoginButtonEnabled() && !isLoading
                          ? handleLogin
                          : null,
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.buttonText,
                              ),
                            ),
                          )
                          : const Text('Continue'),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('or', style: theme.textTheme.bodySmall),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.facebook),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  IconButton(icon: const Icon(Icons.apple), onPressed: () {}),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.g_mobiledata),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: theme.textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: navigateToSignUp,
                    child: const Text('Sign up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
