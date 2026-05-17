import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gearup_garage/data/services/auth_service.dart';

class AuthResult {
  final bool ok;
  final String? message;
  const AuthResult({required this.ok, this.message});
}

class AuthController extends ChangeNotifier {
  AuthController({AuthService? authService, FirebaseFirestore? firestore})
    : _authService = authService ?? AuthService(),
      _firestore = firestore ?? FirebaseFirestore.instance;

  final AuthService _authService;
  final FirebaseFirestore _firestore;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<AuthResult> signInCustomer(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmail(email, password);
      return const AuthResult(ok: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(ok: false, message: _mapAuthError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> signInServiceProvider(
    String email,
    String password,
  ) async {
    _setLoading(true);
    try {
      final userCred = await _authService.signInWithEmail(email, password);
      final doc =
          await _firestore
              .collection('service_providers')
              .doc(userCred.user!.uid)
              .get();

      if (!doc.exists) {
        await _authService.signOut();
        return const AuthResult(
          ok: false,
          message: 'This account is not registered as a service provider',
        );
      }

      final data = doc.data() ?? {};
      if (data['isVerified'] == false) {
        return const AuthResult(
          ok: false,
          message: 'Your account is pending verification. Please wait.',
        );
      }

      return const AuthResult(ok: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(ok: false, message: _mapAuthError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> signInAdmin(
    String email,
    String password, {
    required String adminEmail,
    required String adminPassword,
  }) async {
    _setLoading(true);
    try {
      if (email.trim() != adminEmail || password != adminPassword) {
        return const AuthResult(
          ok: false,
          message: 'Invalid admin credentials.',
        );
      }

      await _authService.signInWithEmail(email, password);
      return const AuthResult(ok: true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return const AuthResult(
          ok: false,
          message:
              'Admin account not found in Firebase. Create it with this email.',
        );
      }
      return AuthResult(ok: false, message: _mapAuthError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> signUpCustomer({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final userCred = await _authService.registerWithEmail(email, password);
      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'uid': userCred.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const AuthResult(ok: true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return _recoverCustomerProfile(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
        );
      }
      return AuthResult(ok: false, message: _mapAuthError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> signUpServiceProvider({
    required String businessName,
    required String ownerName,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final userCred = await _authService.registerWithEmail(email, password);
      await _firestore
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
      return const AuthResult(ok: true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return _recoverServiceProviderProfile(
          businessName: businessName,
          ownerName: ownerName,
          email: email,
          phone: phone,
          address: address,
          password: password,
        );
      }
      return AuthResult(ok: false, message: _mapAuthError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> _recoverCustomerProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final userCred = await _authService.signInWithEmail(email, password);
      final doc =
          await _firestore.collection('users').doc(userCred.user!.uid).get();
      if (doc.exists) {
        return const AuthResult(
          ok: false,
          message: 'Email already registered. Please sign in.',
        );
      }

      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'uid': userCred.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const AuthResult(ok: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(ok: false, message: _mapAuthError(e));
    }
  }

  Future<AuthResult> _recoverServiceProviderProfile({
    required String businessName,
    required String ownerName,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    try {
      final userCred = await _authService.signInWithEmail(email, password);
      final doc =
          await _firestore
              .collection('service_providers')
              .doc(userCred.user!.uid)
              .get();
      if (doc.exists) {
        return const AuthResult(
          ok: false,
          message: 'Email already registered. Please sign in.',
        );
      }

      await _firestore
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
      return const AuthResult(ok: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(ok: false, message: _mapAuthError(e));
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'email-already-in-use':
        return 'Email already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
