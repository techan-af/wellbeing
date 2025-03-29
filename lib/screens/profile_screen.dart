import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // Placeholder function for editing the profile picture.
  void _editProfilePicture(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Profile Picture tapped')),
    );
  }

  // Placeholder function for tapping on a settings option.
  void _onSettingTap(BuildContext context, String settingName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$settingName tapped')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Profile Icon with Pencil Icon Overlay
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _editProfilePicture(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Settings Options
            _buildSettingsTile(
                context, Icons.person, 'Account', () => _onSettingTap(context, 'Account')),
            const Divider(),
            _buildSettingsTile(context, Icons.notifications, 'Notifications',
                () => _onSettingTap(context, 'Notifications')),
            const Divider(),
            _buildSettingsTile(
                context, Icons.lock, 'Privacy', () => _onSettingTap(context, 'Privacy')),
            const Divider(),
            _buildSettingsTile(
                context, Icons.info, 'About', () => _onSettingTap(context, 'About')),
            const Divider(),
            _buildSettingsTile(
                context, Icons.security, 'Security', () => _onSettingTap(context, 'Security')),
            const Divider(),
            _buildSettingsTile(
                context, Icons.language, 'Language', () => _onSettingTap(context, 'Language')),
            const Divider(),
            _buildSettingsTile(
                context, Icons.palette, 'Theme', () => _onSettingTap(context, 'Theme')),
            const Divider(),
            _buildSettingsTile(
                context, Icons.help, 'Help & Support', () => _onSettingTap(context, 'Help & Support')),
            const Divider(),
            _buildSettingsTile(
                context, Icons.feedback, 'Feedback', () => _onSettingTap(context, 'Feedback')),
            const Divider(),
            _buildSettingsTile(
                context, Icons.logout, 'Logout', () => _onSettingTap(context, 'Logout')),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
