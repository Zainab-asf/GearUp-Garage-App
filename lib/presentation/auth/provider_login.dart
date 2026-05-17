import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gearup_garage/presentation/state/auth_controller.dart';
import 'package:gearup_garage/core/ui/app_scaffold.dart';
import 'package:gearup_garage/core/utils/app_snackbar.dart';
import 'package:gearup_garage/core/utils/input_validators.dart';
import 'package:gearup_garage/presentation/provider/provider_dashboard.dart';
import 'package:gearup_garage/presentation/auth/provider_signup.dart';

class ServiceProviderLogin extends StatefulWidget {
  const ServiceProviderLogin({super.key});

  @override
  State<ServiceProviderLogin> createState() => _ServiceProviderLoginState();
}

class _ServiceProviderLoginState extends State<ServiceProviderLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void handleLogin() async {
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
    final result = await auth.signInServiceProvider(email, password);

    if (!mounted) return;

    if (!result.ok) {
      showAppSnackBar(context, result.message ?? 'Login failed', isError: true);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ServiceProviderDashboard()),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = context.watch<AuthController>().isLoading;

    return AppScaffold(
      appBar: AppBar(title: const Text('Provider Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back', style: theme.textTheme.displaySmall),
              const SizedBox(height: 6),
              Text(
                'Manage services, bookings, and chats from one place.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Business email',
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleLogin,
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Continue'),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: theme.textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ServiceProviderSignup(),
                          ),
                        ),
                    child: const Text('Register'),
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
