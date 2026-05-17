import 'package:flutter/material.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/core/ui/app_scaffold.dart';

class RoleDashboard extends StatelessWidget {
  const RoleDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Choose Your Lane')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Who are you today?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a role to personalize your experience.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _RoleButton(
                    icon: Icons.person,
                    label: 'Customer',
                    helper: 'Book services and shop parts',
                    onTap: () => Navigator.pushNamed(context, 'login'),
                  ),
                  _RoleButton(
                    icon: Icons.admin_panel_settings,
                    label: 'Admin',
                    helper: 'Manage approvals and services',
                    onTap: () => Navigator.pushNamed(context, 'admin_login'),
                  ),
                  _RoleButton(
                    icon: Icons.build_circle,
                    label: 'Service Provider',
                    helper: 'Run your garage operations',
                    onTap:
                        () => Navigator.pushNamed(
                          context,
                          'service_provider_login',
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String helper;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.label,
    required this.helper,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.inputBorder),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowSoft,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              helper,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
