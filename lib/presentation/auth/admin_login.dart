import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gearup_garage/presentation/state/auth_controller.dart';
import 'package:gearup_garage/core/ui/app_scaffold.dart';
import 'package:gearup_garage/core/utils/app_snackbar.dart';
import 'package:gearup_garage/core/utils/input_validators.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  static const String adminEmail = 'admin@gearupgarage.com';
  static const String adminPassword = 'admin123';

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final result = await auth.signInAdmin(
      _emailController.text.trim(),
      _passwordController.text,
      adminEmail: adminEmail,
      adminPassword: adminPassword,
    );

    if (!mounted) return;

    if (!result.ok) {
      showAppSnackBar(context, result.message ?? 'Login failed', isError: true);
      return;
    }

    Navigator.pushReplacementNamed(context, 'admin_dashboard');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = context.watch<AuthController>().isLoading;

    return AppScaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Secure access', style: theme.textTheme.displaySmall),
                const SizedBox(height: 6),
                Text(
                  'Review providers, services, and bookings.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Admin email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    final emailError = AppValidators.validateEmail(value ?? '');
                    return emailError;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
