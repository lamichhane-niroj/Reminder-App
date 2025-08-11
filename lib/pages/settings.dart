import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_list/providers/category_provider.dart';
import 'package:todo_list/providers/settings_provider.dart';
import 'package:todo_list/services/foreground_service_helper.dart';
import 'package:todo_list/utils/app_theme.dart';
import 'package:todo_list/utils/styles.dart';
import 'package:todo_list/models/category_model.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final categories = ref.watch(categoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6D83F2),
                  Color(0xFF4A4E69),
                  Color(0xFF22223B),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                          child: Icon(Icons.settings, color: theme.colorScheme.primary, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Settings",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            final router = GoRouter.of(context);
                            if (router.canPop()) {
                              router.pop();
                            } else {
                              router.go('/');
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // General Section
                    _settingsSection(
                      context,
                      title: "General",
                      children: [
                        _settingsTile(
                          context,
                          icon: Icons.verified,
                          title: "Remove Ads",
                          subtitle: "One payment to remove ads forever.",
                        ),
                        _toggleTile(
                          context,
                          icon: Icons.check_circle_outline,
                          title: "Confirm finishing tasks",
                          value: notifier.getBool('confirmFinishingTasks'),
                          onChanged: (val) => notifier.updateSetting('confirmFinishingTasks', val.toString()),
                        ),
                        _toggleTile(
                          context,
                          icon: Icons.repeat,
                          title: "Confirm repeating tasks",
                          value: notifier.getBool('confirmRepeatingTasks'),
                          onChanged: (val) => notifier.updateSetting('confirmRepeatingTasks', val.toString()),
                        ),
                        _toggleTile(
                          context,
                          icon: Icons.paste,
                          title: "Found in clipboard",
                          value: notifier.getBool('foundInClipboard'),
                          onChanged: (val) => notifier.updateSetting('foundInClipboard', val.toString()),
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.list_alt,
                          title: "List to show at startup",
                          subtitle: settings['startupCategory'] ?? 'Default',
                          onTap: () {
                            final selected = settings['startupCategory'] ?? 'Default';
                            showDialog(
                              context: context,
                              builder: (context) {
                                String tempSelected = selected;
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  title: Text("List to show at startup", style: AppStyles.dialogBoxTitle.copyWith(fontFamily: 'Poppins')),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: categories.map((cat) {
                                        return RadioListTile<String>(
                                          title: Text(cat.name),
                                          value: cat.name,
                                          groupValue: tempSelected,
                                          onChanged: (value) {
                                            if (value != null) {
                                              ref.read(settingsProvider.notifier).updateSetting('startupCategory', value);
                                              Navigator.of(context).pop();
                                            }
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.calendar_today,
                          title: "First day of week",
                          subtitle: settings['firstDayOfWeek'] ?? 'Sunday',
                          onTap: () {
                            String selectedDay = settings['firstDayOfWeek'] ?? 'Sunday';
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  title: Text("First day of week", style: AppStyles.dialogBoxTitle.copyWith(fontFamily: 'Poppins')),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: ["Saturday", "Sunday", "Monday"].map((day) {
                                      return RadioListTile<String>(
                                        title: Text(day),
                                        value: day,
                                        groupValue: selectedDay,
                                        onChanged: (value) {
                                          if (value != null) {
                                            ref.read(settingsProvider.notifier).updateSetting('firstDayOfWeek', value);
                                            Navigator.of(context).pop();
                                          }
                                        },
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.access_time,
                          title: "Time format",
                          subtitle: settings['timeFormat'] ?? '12-hour',
                          onTap: () {
                            String selectedFormat = settings['timeFormat'] ?? '12-hour';
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                title: Text("Time format", style: AppStyles.dialogBoxTitle.copyWith(fontFamily: 'Poppins')),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: ["12-hour", "24-hour"].map((format) {
                                    return RadioListTile<String>(
                                      title: Text(format),
                                      value: format,
                                      groupValue: selectedFormat,
                                      onChanged: (value) {
                                        if (value != null) {
                                          ref.read(settingsProvider.notifier).updateSetting('timeFormat', value);
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                        _toggleTile(
                          context,
                          icon: Icons.dark_mode,
                          title: "Dark Mode",
                          value: notifier.getBool('darkMode'),
                          onChanged: (val) => notifier.updateSetting('darkMode', val.toString()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Notifications Section
                    _settingsSection(
                      context,
                      title: "Notifications",
                      children: [
                        _settingsTile(
                          context,
                          icon: Icons.music_note,
                          title: "Sound",
                          subtitle: "Default",
                        ),
                        _toggleTile(
                          context,
                          icon: Icons.record_voice_over,
                          title: "Voice",
                          value: notifier.getBool('isVoiceOn'),
                          onChanged: (val) => notifier.updateSetting('isVoiceOn', val.toString()),
                        ),
                        _toggleTile(
                          context,
                          icon: Icons.vibration,
                          title: "Vibration",
                          value: notifier.getBool('isVibrationOn'),
                          onChanged: (val) => notifier.updateSetting('isVibrationOn', val.toString()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Quick Task Section
                    _settingsSection(
                      context,
                      title: "Quick Task",
                      children: [
                        _toggleTile(
                          context,
                          icon: Icons.flash_on,
                          title: "Quick task bar",
                          value: notifier.getBool('quickTaskbar'),
                          onChanged: (val) => notifier.updateSetting('quickTaskbar', val.toString()),
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.event_note,
                          title: "Default due date",
                          subtitle: "No date",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // About Section
                    _settingsSection(
                      context,
                      title: "About",
                      children: [
                        _settingsTile(
                          context,
                          icon: Icons.group_add,
                          title: "Invite friends to the app",
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.apps,
                          title: "More Apps",
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.feedback,
                          title: "Send feedback",
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.info_outline,
                          title: "SunsariDev",
                          subtitle: "Version 1.0",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Follow Us Section
                    _settingsSection(
                      context,
                      title: "Follow us",
                      children: [
                        _settingsTile(
                          context,
                          icon: Icons.facebook,
                          title: "Facebook",
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.camera_alt,
                          title: "Instagram",
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.alternate_email,
                          title: "Twitter",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section card with title and children
  Widget _settingsSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ),
        Card(
          color: Colors.white.withOpacity(0.07),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  // Settings tile with icon, title, subtitle, and optional onTap
  Widget _settingsTile(BuildContext context, {required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 26),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white.withOpacity(0.7),
              ),
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: Colors.white.withOpacity(0.04),
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
    );
  }

  // Toggle tile with icon, title, value, and onChanged
  Widget _toggleTile(BuildContext context, {required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 26),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
      inactiveThumbColor: Colors.white54,
      inactiveTrackColor: Colors.white24,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
