import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gearup_garage/presentation/state/auth_controller.dart';
import 'package:gearup_garage/core/ui/app_scaffold.dart';
import 'package:gearup_garage/core/utils/app_snackbar.dart';
import 'package:gearup_garage/core/utils/input_validators.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';

class ServiceProviderSignup extends StatefulWidget {
  const ServiceProviderSignup({super.key});

  @override
  State<ServiceProviderSignup> createState() => _ServiceProviderSignupState();
}

class _ServiceProviderSignupState extends State<ServiceProviderSignup> {
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void handleSignup() async {
    final businessName = businessNameController.text.trim();
    final ownerName = ownerNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (businessName.isEmpty ||
        ownerName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        address.isEmpty) {
      showAppSnackBar(context, 'Please fill all fields', isError: true);
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
    final result = await auth.signUpServiceProvider(
      businessName: businessName,
      ownerName: ownerName,
      email: email,
      phone: phone,
      address: address,
      password: password,
    );

    if (!mounted) return;

    if (!result.ok) {
      showAppSnackBar(
        context,
        result.message ?? 'Registration failed',
        isError: true,
      );
      return;
    }

    showAppSnackBar(
      context,
      'Registration successful! Please wait for verification.',
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    businessNameController.dispose();
    ownerNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = context.watch<AuthController>().isLoading;

    return AppScaffold(
      appBar: AppBar(title: const Text('Register Business')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grow with GearUp Garage',
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Submit your business details for verification.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              TextField(
                controller: businessNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Business name',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ownerNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Owner name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Business email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Business address',
                  prefixIcon: Icon(Icons.location_on),
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
                          : const Text('Submit for review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
