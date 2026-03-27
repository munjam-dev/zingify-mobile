import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZingifyColors.background,
      appBar: AppBar(
        backgroundColor: ZingifyColors.surface,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: ZingifyColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: ZingifyColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App Settings
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'App Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ZingifyColors.onSurface,
                      ),
                    ),
                  ),
                  _buildSettingTile(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: 'Toggle dark theme',
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {},
                      activeColor: ZingifyColors.primary,
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Manage notifications',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () {},
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // Chat Settings
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Chat Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ZingifyColors.onSurface,
                      ),
                    ),
                  ),
                  _buildSettingTile(
                    icon: Icons.wallpaper,
                    title: 'Wallpaper',
                    subtitle: 'Change chat wallpaper',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    icon: Icons.font_download,
                    title: 'Font Size',
                    subtitle: 'Medium',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    icon: Icons.download,
                    title: 'Download Media',
                    subtitle: 'Auto-download on Wi-Fi',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                      activeColor: ZingifyColors.primary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // About
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ZingifyColors.onSurface,
                      ),
                    ),
                  ),
                  _buildSettingTile(
                    icon: Icons.info,
                    title: 'Version',
                    subtitle: '1.0.0',
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    icon: Icons.description,
                    title: 'Terms of Service',
                    onTap: () {},
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ZingifyColors.primary, ZingifyColors.secondary],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: ZingifyColors.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: ZingifyColors.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: ZingifyColors.primary),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: ZingifyColors.border,
      indent: 72,
    );
  }
}
