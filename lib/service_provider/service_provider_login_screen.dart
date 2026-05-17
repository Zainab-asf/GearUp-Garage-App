import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_provider_dashboard_screen.dart';
import 'service_provider_signup_screen.dart';
import '../theme.dart';

class ServiceProviderLogin extends StatefulWidget {
  const ServiceProviderLogin({super.key});

  @override
  State<ServiceProviderLogin> createState() => _ServiceProviderLoginState();
}

class _ServiceProviderLoginState extends State<ServiceProviderLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // Password visibility
  bool _isPasswordVisible = false;

  void handleLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showSnackBar('Please enter a valid email');
      return;
    }

    // Enhanced password validation
    String? passwordError = _validatePassword(password);
    if (passwordError != null) {
      _showSnackBar(passwordError);
      return;
    }

    setState(() => isLoading = true);

    try {
      // Authenticate user
      final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user is a service provider
      final serviceProviderDoc =
          await FirebaseFirestore.instance
              .collection('service_providers')
              .doc(userCred.user!.uid)
              .get();

      if (!serviceProviderDoc.exists) {
        await FirebaseAuth.instance.signOut();
        _showSnackBar('This account is not registered as a service provider');
        return;
      }

      final serviceProviderData = serviceProviderDoc.data()!;

      if (serviceProviderData['isVerified'] == false) {
        _showSnackBar(
          'Your account is pending verification. Please wait for approval.',
        );
        return;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ServiceProviderDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No service provider found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many failed attempts. Please try again later.';
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Password validation method
  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }

    return null; // Password is valid
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Icon
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Icon(
                        Icons.storefront,
                        size: 56,
                        color: theme.primaryColor,
                      ),
                    ),
                    // Header
                    Text(
                      'Welcome Service Provider',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to your account',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Email Field
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: emailController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppTheme.inputIcon,
                          ),
                          hintText: 'E-mail',
                          hintStyle: TextStyle(
                            color: AppTheme.primary,
                          ),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: AppTheme.inputFill,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    TextField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppTheme.inputIcon,
                        ),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: AppTheme.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppTheme.inputIcon,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: AppTheme.inputFill,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleLogin,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child:
                            isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Divider with 'or'
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('or', style: theme.textTheme.bodyMedium),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Social Login Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.facebook,
                            color: AppTheme.inputIcon,
                          ),
                          onPressed:
                              () =>
                                  _showSnackBar('Facebook login coming soon!'),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(
                            Icons.apple,
                            color: AppTheme.inputIcon,
                          ),
                          onPressed:
                              () => _showSnackBar('Apple login coming soon!'),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(
                            Icons.g_mobiledata,
                            color: AppTheme.inputIcon,
                          ),
                          onPressed:
                              () => _showSnackBar('Google login coming soon!'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ServiceProviderSignup(),
                                ),
                              ),
                          child: Text(
                            'Sign up',
                            style: const TextStyle(
                              color: AppTheme.buttonPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Back Button (always top left)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
