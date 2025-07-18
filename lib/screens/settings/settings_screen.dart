import 'package:flutter/material.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'package:flutter_bball_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final settingsService = Provider.of<SettingsService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Settings',
                style: textTheme.headlineLarge?.copyWith(
                  color: const Color(0xFFf9fafb),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Customize your workout experience.',
                style: textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF9ca3af),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Audio Cues'),
              const SizedBox(height: 16),
              Consumer<SettingsService>(
                builder: (context, settings, child) {
                  return Column(
                    children: [
                      _buildSettingTile(
                        context: context,
                        title: 'Announce Drill Name',
                        subtitle: 'Speak the drill name when starting a new drill',
                        value: settings.announceDrillName,
                        onChanged: (value) => settings.setAnnounceDrillName(value),
                      ),
                      const SizedBox(height: 12),
                      _buildSettingTile(
                        context: context,
                        title: 'Announce Drill Description',
                        subtitle: 'Speak the drill description when starting a new drill',
                        value: settings.announceDrillDescription,
                        onChanged: (value) => settings.setAnnounceDrillDescription(value),
                      ),
                      const SizedBox(height: 12),
                      _buildSettingTile(
                        context: context,
                        title: 'Announce Target Makes',
                        subtitle: 'Speak the target makes for drills that have targets',
                        value: settings.announceDrillTargetMakes,
                        onChanged: (value) => settings.setAnnounceDrillTargetMakes(value),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Account'),
              const SizedBox(height: 16),
              Consumer<AuthService>(
                builder: (context, authService, child) {
                  final user = authService.currentUser;
                  return Column(
                    children: [
                      if (user != null) ...[
                        _buildAccountTile(
                          context: context,
                          title: 'Email',
                          subtitle: user.email ?? 'No email',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 12),
                        if (user.displayName != null) ...[
                          _buildAccountTile(
                            context: context,
                            title: 'Name',
                            subtitle: user.displayName!,
                            icon: Icons.person_outlined,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                      _buildActionTile(
                        context: context,
                        title: 'Sign Out',
                        subtitle: 'Sign out of your account',
                        icon: Icons.logout,
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Sign Out'),
                              content: const Text('Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Sign Out'),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirmed == true) {
                            try {
                              await authService.signOut();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to sign out: $e'),
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.titleLarge?.copyWith(
        color: const Color(0xFF3b82f6),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1f2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4b5563)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFf9fafb),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9ca3af),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3b82f6),
            activeTrackColor: const Color(0xFF3b82f6).withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1f2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4b5563)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF3b82f6),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFf9fafb),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9ca3af),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1f2937),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4b5563)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFef4444),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFf9fafb),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF9ca3af),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9ca3af),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}