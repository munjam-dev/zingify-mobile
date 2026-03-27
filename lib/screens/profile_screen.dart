import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZingifyColors.background,
      appBar: AppBar(
        backgroundColor: ZingifyColors.surface,
        elevation: 0,
        title: const Text(
          'Profile',
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
            // Profile Header
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: ZingifyColors.primary,
                    child: const Text(
                      'ME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ZingifyColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+91 98765 43210',
                    style: TextStyle(
                      color: ZingifyColors.onSurface.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // Profile Options
            GlassContainer(
              child: Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    subtitle: 'Update your name and status',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Manage notification settings',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    icon: Icons.privacy_tip,
                    title: 'Privacy',
                    subtitle: 'Control your privacy settings',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    icon: Icons.security,
                    title: 'Security',
                    subtitle: 'Manage security settings',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    icon: Icons.help,
                    title: 'Help',
                    subtitle: 'Get help and support',
                    onTap: () {},
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: ZingifyColors.onSurface.withOpacity(0.6),
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: ZingifyColors.primary),
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
