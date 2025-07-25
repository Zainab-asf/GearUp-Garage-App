import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_provider_dashboard_screen.dart';
import '../theme.dart';

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
  bool isLoading = false;

  void handleSignup() async {
    final businessName = businessNameController.text.trim();
    final ownerName = ownerNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validation
    if (businessName.isEmpty ||
        ownerName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        address.isEmpty) {
      _showSnackBar('Please fill all fields');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showSnackBar('Please enter a valid email');
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password must be at least 6 characters');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match');
      return;
    }

    setState(() => isLoading = true);

    try {
      // Create user account
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Store service provider data
      await FirebaseFirestore.instance
          .collection('service_providers')
          .doc(userCred.user!.uid)
          .set({
            'businessName': businessName,
            'ownerName': ownerName,
            'email': email,
            'phone': phone,
            'address': address,
            'uid': userCred.user!.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'isVerified': false,
            'services': [],
          });

      _showSnackBar('Registration successful! Please wait for verification.');
      clearFields();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ServiceProviderDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        message = 'Email already registered';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('Something went wrong');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void clearFields() {
    businessNameController.clear();
    ownerNameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
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
                        Icons.storefront,
                        size: 56,
                        color: theme.primaryColor,
                      ),
                    ),
                    // Header
                    Text(
                      'Register Your Business',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Join our network of trusted service providers',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Business Name
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: businessNameController,
                        style: const TextStyle(color: AppTheme.primary),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.business,
                            color: AppTheme.inputIcon,
                          ),
                          hintText: 'Business Name',
                          hintStyle: TextStyle(color: AppTheme.primary),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: AppTheme.inputFill,
                        ),
                      ),
                    ),
                    // Owner Name
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: ownerNameController,
                        style: const TextStyle(color: AppTheme.primary),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppTheme.inputIcon,
                          ),
                          hintText: 'Owner Name',
                          hintStyle: TextStyle(color: AppTheme.primary),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: AppTheme.inputFill,
                        ),
                      ),
                    ),
                    // Email
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: emailController,
                        style: const TextStyle(color: AppTheme.primary),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppTheme.inputIcon,
                          ),
                          hintText: 'Business Email',
                          hintStyle: TextStyle(color: AppTheme.primary),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: AppTheme.inputFill,
                        ),
                      ),
                    ),
                    // Phone
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: phoneController,
                        style: const TextStyle(color: AppTheme.primary),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.phone,
                            color: AppTheme.inputIcon,
                          ),
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(color: AppTheme.primary),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: AppTheme.inputFill,
                        ),
                      ),
                    ),
                    // Address
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: addressController,
                        style: const TextStyle(color: AppTheme.primary),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: AppTheme.inputIcon,
                          ),
                          hintText: 'Business Address',
                          hintStyle: TextStyle(color: AppTheme.primary),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: AppTheme.inputFill,
                        ),
                      ),
                    ),
                    // Password
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: passwordController,
                        style: const TextStyle(color: AppTheme.primary),
                        obscureText: true,
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
                        ),
                      ),
                    ),
                    // Confirm Password
                    Container(
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: confirmPasswordController,
                        style: const TextStyle(color: AppTheme.primary),
                        obscureText: true,
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
                        ),
                      ),
                    ),
                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child:
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                onPressed: isLoading ? null : handleSignup,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text('Register Business'),
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
                          icon: const Icon(Icons.facebook),
                          onPressed:
                              () =>
                                  _showSnackBar('Facebook signup coming soon!'),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(Icons.apple),
                          onPressed:
                              () => _showSnackBar('Apple signup coming soon!'),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(Icons.g_mobiledata),
                          onPressed:
                              () => _showSnackBar('Google signup coming soon!'),
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
