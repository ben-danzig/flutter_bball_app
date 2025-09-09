import 'package:flutter/material.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'package:flutter_bball_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
                      const SizedBox(height: 12),
                      _buildSettingTile(
                        context: context,
                        title: 'Timer Sound Effects',
                        subtitle: 'Play a sound when the timer completes',
                        value: settings.playTimerSounds,
                        onChanged: (value) => settings.setPlayTimerSounds(value),
                        switchKey: const Key('settings_timer_sound_effects_switch'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Voice Commands'),
              const SizedBox(height: 16),
              Consumer<SettingsService>(
                builder: (context, settings, child) {
                  return Column(
                    children: [
                      _buildSettingTile(
                        context: context,
                        title: 'Enable Voice Commands',
                        subtitle: 'Use voice commands to control your workout',
                        value: settings.voiceCommandsEnabled,
                        onChanged: (value) => settings.setVoiceCommandsEnabled(value),
                      ),
                      const SizedBox(height: 12),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: settings.voiceCommandsEnabled
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          children: [
                            _buildSettingTile(
                              context: context,
                              title: 'Audio Command Feedback',
                              subtitle: 'Play confirmation sounds for voice commands',
                              value: settings.audioCommandFeedback,
                              onChanged: (value) => settings.setAudioCommandFeedback(value),
                            ),
                            const SizedBox(height: 12),
                            _buildConfidenceThresholdTile(
                              context: context,
                              value: settings.voiceConfidenceThreshold,
                              onChanged: (value) => settings.setVoiceConfidenceThreshold(value),
                            ),
                            const SizedBox(height: 12),
                            _buildMicrophonePermissionTile(context),
                            const SizedBox(height: 12),
                            _buildVoiceCommandsInfoTile(context),
                          ],
                        ),
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
    Key? switchKey,
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
            key: switchKey,
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

  Widget _buildConfidenceThresholdTile({
    required BuildContext context,
    required double value,
    required Function(double) onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1f2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4b5563)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Voice Recognition Confidence',
                style: textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFf9fafb),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF3b82f6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Higher values require clearer pronunciation',
            style: textTheme.bodySmall?.copyWith(
              color: const Color(0xFF9ca3af),
            ),
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF3b82f6),
              inactiveTrackColor: const Color(0xFF4b5563),
              thumbColor: const Color(0xFF3b82f6),
              overlayColor: const Color(0xFF3b82f6).withOpacity(0.3),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: 0.5,
              max: 0.9,
              divisions: 8,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicrophonePermissionTile(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<PermissionStatus>(
      future: Permission.microphone.status,
      builder: (context, snapshot) {
        final status = snapshot.data;
        final isGranted = status == PermissionStatus.granted;
        final isDenied = status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied;

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
                isGranted ? Icons.mic : Icons.mic_off,
                color: isGranted ? const Color(0xFF10b981) : const Color(0xFFef4444),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Microphone Permission',
                      style: textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFf9fafb),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGranted
                          ? 'Permission granted'
                          : isDenied
                              ? 'Permission denied - tap to enable'
                              : 'Checking permission...',
                      style: textTheme.bodySmall?.copyWith(
                        color: isGranted ? const Color(0xFF10b981) : const Color(0xFF9ca3af),
                      ),
                    ),
                  ],
                ),
              ),
              if (isDenied)
                TextButton(
                  onPressed: () async {
                    final result = await Permission.microphone.request();
                    if (result.isPermanentlyDenied) {
                      await openAppSettings();
                    }
                  },
                  child: const Text('Enable'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoiceCommandsInfoTile(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1f2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4b5563)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF3b82f6),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'How to Use Voice Commands',
                style: textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFf9fafb),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Say "Hey Coach" to activate voice commands, then say:',
            style: textTheme.bodySmall?.copyWith(
              color: const Color(0xFF9ca3af),
            ),
          ),
          const SizedBox(height: 8),
          _buildCommandExample(textTheme, '• "Pause" or "Resume" - Control workout'),
          _buildCommandExample(textTheme, '• "Next" or "Previous" - Navigate drills'),
          _buildCommandExample(textTheme, '• "Reset" - Restart current drill'),
          _buildCommandExample(textTheme, '• "Made X shots" - Log successful shots'),
          const SizedBox(height: 8),
          Text(
            'During shooting drills, you can also say "Make" or "Miss" to track shots.',
            style: textTheme.bodySmall?.copyWith(
              color: const Color(0xFF9ca3af),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandExample(TextTheme textTheme, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 2),
      child: Text(
        text,
        style: textTheme.bodySmall?.copyWith(
          color: const Color(0xFFd1d5db),
        ),
      ),
    );
  }
}