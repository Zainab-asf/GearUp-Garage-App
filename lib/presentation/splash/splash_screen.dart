import 'package:flutter/material.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/core/ui/app_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to role dashboard after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/role_dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      useSafeArea: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowStrong,
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/03.jpeg',
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'GearUp Garage',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Fast bookings. Trusted garages. Zero hassle.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 160,
                child: LinearProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation(AppTheme.secondary),
                  backgroundColor: AppTheme.inputBorder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
