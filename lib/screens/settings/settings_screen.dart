import 'package:flutter/material.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
}