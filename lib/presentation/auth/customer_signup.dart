import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gearup_garage/presentation/state/auth_controller.dart';
import 'package:gearup_garage/core/ui/app_scaffold.dart';
import 'package:gearup_garage/core/utils/app_snackbar.dart';
import 'package:gearup_garage/core/utils/input_validators.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';

class MySignup extends StatefulWidget {
  const MySignup({super.key});

  @override
  State<MySignup> createState() => _MySignupState();
}

class _MySignupState extends State<MySignup> {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void handleSignup() async {
    final firstname = firstnameController.text.trim();
    final lastname = lastnameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (firstname.isEmpty || lastname.isEmpty) {
      showAppSnackBar(context, 'Enter your full name', isError: true);
      return;
    }

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

    if (password != confirmPassword) {
      showAppSnackBar(context, 'Passwords do not match', isError: true);
      return;
    }

    final auth = context.read<AuthController>();
    final result = await auth.signUpCustomer(
      firstName: firstname,
      lastName: lastname,
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (!result.ok) {
      showAppSnackBar(
        context,
        result.message ?? 'Signup failed',
        isError: true,
      );
      return;
    }

    showAppSnackBar(context, 'Registration successful!');
    clearFields();
    Navigator.pop(context);
  }

  void clearFields() {
    firstnameController.clear();
    lastnameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = context.watch<AuthController>().isLoading;

    return AppScaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Join GearUp Garage', style: theme.textTheme.displaySmall),
              const SizedBox(height: 6),
              Text(
                'Set up your profile and start booking trusted services.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: firstnameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'First name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: lastnameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Last name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
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
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
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
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleSignup,
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
                          : const Text('Create account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
