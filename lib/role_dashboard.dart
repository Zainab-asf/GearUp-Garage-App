import 'package:flutter/material.dart';
import 'theme.dart';

class RoleDashboard extends StatelessWidget {
  const RoleDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final double iconSize = 48;
    final double buttonHeight = 150;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Select User Type'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.background.withValues(alpha: 0.7),
              AppTheme.background.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _RoleButton(
                  icon: Icons.person,
                  label: 'Customer',
                  color: AppTheme.secondary,
                  onTap: () => Navigator.pushNamed(context, 'login'),
                  iconSize: iconSize,
                  height: buttonHeight,
                ),
                _RoleButton(
                  icon: Icons.admin_panel_settings,
                  label: 'Admin',
                  color: AppTheme.secondary,
                  onTap: () => Navigator.pushNamed(context, 'admin_login'),
                  iconSize: iconSize,
                  height: buttonHeight,
                ),
                _RoleButton(
                  icon: Icons.build_circle,
                  label: 'Service Provider',
                  color: AppTheme.secondary,
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        'service_provider_login',
                      ),
                  iconSize: iconSize,
                  height: buttonHeight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double iconSize;
  final double height;

  const _RoleButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.iconSize,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        height: height,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.white, size: iconSize),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.1,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
