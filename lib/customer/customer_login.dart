import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customer_signup.dart';
import 'customer_home.dart';
import '../theme.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Password visibility
  bool _isPasswordVisible = false;

  // Login attempt tracking
  int _failedAttempts = 0;
  DateTime? _blockUntil;
  bool _isBlocked = false;
  Timer? _blockTimer;

  void handleLogin() async {
    // Check if user is currently blocked
    if (_isBlocked && _blockUntil != null) {
      final now = DateTime.now();
      if (now.isBefore(_blockUntil!)) {
        final remainingSeconds = _blockUntil!.difference(now).inSeconds;
        _showSnackBar(
          'Too many failed attempts. Try again in $remainingSeconds seconds.',
        );
        return;
      } else {
        // Block period has expired, reset
        _resetLoginAttempts();
      }
    }
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

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Login successful - reset failed attempts
      _resetLoginAttempts();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyHome()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Increment failed attempts
      _handleFailedLogin();

      String message = 'Login failed';
      if (e.code == 'user-not-found') message = 'No user found for that email.';
      if (e.code == 'wrong-password') message = 'Incorrect password.';
      if (e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      }
      if (e.code == 'too-many-requests') {
        message = 'Too many requests. Try again later.';
      }

      _showSnackBar(message);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
        _showSnackBar(
          'Too many failed attempts. Login blocked for 10 seconds.',
        );
        _startBlockTimer();
      } else {
        final remainingAttempts = 3 - _failedAttempts;
        _showSnackBar('Login failed. $remainingAttempts attempts remaining.');
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
        setState(() {}); // Trigger UI update to show countdown
      }
    });
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

  @override
  void dispose() {
    _blockTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _isLoginButtonEnabled() {
    if (!_isBlocked) return true;
    if (_blockUntil == null) return true;

    final now = DateTime.now();
    if (now.isAfter(_blockUntil!)) {
      // Block period has expired, reset and enable
      _resetLoginAttempts();
      return true;
    }

    return false;
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
                        Icons.person,
                        size: 56,
                        color: theme.primaryColor,
                      ),
                    ),
                    // Header
                    Text(
                      'Welcome Customer',
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
                        style: TextStyle(color: AppTheme.primary),
                        cursorColor: AppTheme.primary,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppTheme.inputIcon,
                          ),
                          hintText: 'E-mail',
                          hintStyle: TextStyle(color: AppTheme.primary),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: AppTheme.inputFill,
                        ),
                      ),
                    ),
                    // Password Field
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(color: AppTheme.primary),
                        cursorColor: AppTheme.primary,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppTheme.inputIcon,
                          ),
                          hintText: 'Password',
                          hintStyle: TextStyle(color: AppTheme.primary),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: AppTheme.inputFill,
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
                        ),
                      ),
                    ),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoginButtonEnabled() ? handleLogin : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.buttonPrimary,
                          foregroundColor: AppTheme.buttonText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Login'),
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
                          icon: Icon(
                            Icons.facebook,
                            color: AppTheme.buttonPrimary,
                          ),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: Icon(
                            Icons.apple,
                            color: AppTheme.buttonPrimary,
                          ),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: Icon(
                            Icons.g_mobiledata,
                            color: AppTheme.buttonPrimary,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: navigateToSignUp,
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
