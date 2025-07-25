import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'splash_screen.dart';

import 'admin/admin_dashboard_screen.dart';
import 'admin/admin_login_screen.dart';

import 'service_provider/service_provider_dashboard_screen.dart';
import 'service_provider/service_provider_login_screen.dart';
import 'service_provider/service_provider_signup_screen.dart';

import 'customer/customer_login.dart';
import 'customer/customer_signup.dart';
import 'customer/customer_home.dart';

import 'role_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "GearUp Garage",
      theme: AppTheme.gradientTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/role_dashboard': (context) => const RoleDashboard(),
        'login': (context) => const MyLogin(),
        'signup': (context) => const MySignup(),
        'home': (context) => const MyHome(),
        'service_provider': (context) => const ServiceProviderDashboard(),
        'service_provider_login': (context) => const ServiceProviderLogin(),
        'service_provider_signup': (context) => const ServiceProviderSignup(),
        'admin_dashboard': (context) => const AdminDashboard(),
        'admin_login': (context) => const AdminLogin(),
      },
    ),
  );
}
