import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:gearup_garage/core/config/firebase-options.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/presentation/splash/splash_screen.dart';
import 'package:gearup_garage/presentation/state/auth_controller.dart';

import 'package:gearup_garage/presentation/admin/admin_dashboard.dart';
import 'package:gearup_garage/presentation/auth/admin_login.dart';

import 'package:gearup_garage/presentation/provider/provider_dashboard.dart';
import 'package:gearup_garage/presentation/auth/provider_login.dart';
import 'package:gearup_garage/presentation/auth/provider_signup.dart';

import 'package:gearup_garage/presentation/auth/customer_login.dart';
import 'package:gearup_garage/presentation/auth/customer_signup.dart';
import 'package:gearup_garage/presentation/customer/customer_home.dart';

import 'package:gearup_garage/presentation/role/role_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthController())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GearUp Garage',
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
    ),
  );
}

