import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MySignup(),
    );
  }
}

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
  bool isLoading = false;

  // Password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void handleSignup() async {
    final firstname = firstnameController.text.trim();
    final lastname = lastnameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (firstname.isEmpty || lastname.isEmpty) {
      return showMessage('Enter full name');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return showMessage('Invalid email');
    }
    // Enhanced password validation
    String? passwordError = _validatePassword(password);
    if (passwordError != null) {
      return showMessage(passwordError);
    }
    if (password != confirmPassword) {
      return showMessage('Passwords do not match');
    }

    setState(() => isLoading = true);
    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
            'firstName': firstname,
            'lastName': lastname,
            'email': email,
            'uid': userCred.user!.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
      showMessage('Registration successful!');
      clearFields();
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      final msg =
          {
            'email-already-in-use': 'Email already registered',
            'invalid-email': 'Invalid email',
            'weak-password': 'Weak password',
            'operation-not-allowed': 'Operation not allowed',
          }[e.code] ??
          'Signup failed';
      showMessage(msg);
    } catch (e) {
      showMessage('Something went wrong');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

  void clearFields() {
    firstnameController.clear();
    lastnameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
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
                        Icons.spa,
                        size: 56,
                        color: theme.primaryColor,
                      ),
                    ),
                    // Header
                    Text(
                      'Create your account',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Join us today!',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Name Fields
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.inputFill,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: firstnameController,
                              style: TextStyle(color: AppTheme.primary),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: AppTheme.inputIcon,
                                ),
                                hintText: 'First Name',
                                hintStyle: TextStyle(color: AppTheme.primary),
                                border: InputBorder.none,
                                filled: true,
                                fillColor: AppTheme.inputFill,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.inputFill,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: lastnameController,
                              style: TextStyle(color: AppTheme.primary),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: AppTheme.inputIcon,
                                ),
                                hintText: 'Last Name',
                                hintStyle: TextStyle(color: AppTheme.primary),
                                border: InputBorder.none,
                                filled: true,
                                fillColor: AppTheme.inputFill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
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
                    const SizedBox(height: 20.0),
                    // Password Field
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: passwordController,
                        style: TextStyle(color: AppTheme.primary),
                        obscureText: !_isPasswordVisible,
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
                    const SizedBox(height: 20.0),
                    // Confirm Password Field
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: confirmPasswordController,
                        style: TextStyle(color: AppTheme.primary),
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppTheme.inputIcon,
                          ),
                          hintText: 'Confirm Password',
                          hintStyle: TextStyle(color: AppTheme.primary),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: AppTheme.inputFill,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppTheme.inputIcon,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleSignup,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text('Sign Up'),
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
                    // Social Signup Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.facebook,
                            color: AppTheme.buttonPrimary,
                          ),
                          onPressed:
                              () => showMessage('Facebook signup coming soon!'),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: Icon(
                            Icons.apple,
                            color: AppTheme.buttonPrimary,
                          ),
                          onPressed:
                              () => showMessage('Apple signup coming soon!'),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: Icon(
                            Icons.g_mobiledata,
                            color: AppTheme.buttonPrimary,
                          ),
                          onPressed:
                              () => showMessage('Google signup coming soon!'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Sign in',
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
