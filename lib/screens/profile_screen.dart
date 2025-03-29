import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // Navigate to the Edit Profile Picture screen.
  void _editProfilePicture(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePictureScreen()),
    );
  }

  // Helper method for navigation to a new screen.
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
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
            // Settings Options with navigation to various scaffolded settings screens
            _buildSettingsTile(
              context,
              Icons.person,
              'Account',
              () => _navigateTo(context, AccountScreen()),
            ),
            const Divider(),
            _buildSettingsTile(
              context,
              Icons.notifications,
              'Notifications',
              () => _navigateTo(context, const NotificationsScreen()),
            ),
            const Divider(),
            _buildSettingsTile(
              context,
              Icons.lock,
              'Privacy',
              () => _navigateTo(context, const PrivacyScreen()),
            ),
            const Divider(),
            _buildSettingsTile(
              context,
              Icons.info,
              'About',
              () => _navigateTo(context, const AboutScreen()),
            ),
            const Divider(),
            _buildSettingsTile(
              context,
              Icons.security,
              'Security',
              () => _navigateTo(context, const SecurityScreen()),
            ),
            const Divider(),
            _buildSettingsTile(
              context,
              Icons.language,
              'Language',
              () => _navigateTo(context, const LanguageScreen()),
            ),
            const Divider(),
            _buildSettingsTile(
              context,
              Icons.palette,
              'Theme',
              () => _navigateTo(context, const ThemeScreen()),
            ),
            const Divider(),
            _buildSettingsTile(
              context,
              Icons.help,
              'Help & Support',
              () => _navigateTo(context, const HelpSupportScreen()),
            ),
            const Divider(),
            _buildSettingsTile(
              context,
              Icons.feedback,
              'Feedback',
              () => _navigateTo(context, const FeedbackScreen()),
            ),
            const Divider(),
            _buildSettingsTile(
              context,
              Icons.logout,
              'Logout',
              () => _navigateTo(context, const LogoutScreen()),
            ),
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

// ---------- Edit Profile Picture Screen ----------
class EditProfilePictureScreen extends StatelessWidget {
  const EditProfilePictureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile Picture')),
      body: const Center(child: Text('Edit Profile Picture Screen')),
    );
  }
}

// ---------- Account Screen with TextFields ----------
// Removed 'const' from the constructor since controllers are non-const.
class AccountScreen extends StatelessWidget {
  AccountScreen({Key? key}) : super(key: key);

  // Dummy controllers
  final TextEditingController nameController =
      TextEditingController(text: 'John Doe');
  final TextEditingController emailController =
      TextEditingController(text: 'john.doe@example.com');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Notifications Screen with SwitchListTiles ----------
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool emailNotifications = true;
  bool pushNotifications = false;
  bool smsNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Email Notifications'),
            value: emailNotifications,
            onChanged: (value) => setState(() => emailNotifications = value),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            value: pushNotifications,
            onChanged: (value) => setState(() => pushNotifications = value),
          ),
          SwitchListTile(
            title: const Text('SMS Notifications'),
            value: smsNotifications,
            onChanged: (value) => setState(() => smsNotifications = value),
          ),
        ],
      ),
    );
  }
}

// ---------- Privacy Screen with CheckboxListTiles ----------
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool showOnlineStatus = true;
  bool shareActivityStatus = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        children: [
          CheckboxListTile(
            title: const Text('Show Online Status'),
            value: showOnlineStatus,
            onChanged: (value) => setState(() => showOnlineStatus = value!),
          ),
          CheckboxListTile(
            title: const Text('Share Activity Status'),
            value: shareActivityStatus,
            onChanged: (value) => setState(() => shareActivityStatus = value!),
          ),
        ],
      ),
    );
  }
}

// ---------- About Screen with Static Content ----------
class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: const Text(
          'This is a demo app to showcase various settings options. '
          'Each section is a placeholder for your actual content.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

// ---------- Security Screen with a Switch for Two-Factor Authentication ----------
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool twoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Two-Factor Authentication'),
            value: twoFactorEnabled,
            onChanged: (value) => setState(() => twoFactorEnabled = value),
          ),
          ListTile(
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ---------- Language Screen with a Dropdown Menu ----------
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = 'English';

  final List<String> languages = ['English', 'Spanish', 'French', 'German'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('Select Language: '),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: selectedLanguage,
              items: languages
                  .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedLanguage = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Theme Screen with Radio Buttons for Theme Selection ----------
class ThemeScreen extends StatefulWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

enum AppTheme { light, dark, system }

class _ThemeScreenState extends State<ThemeScreen> {
  AppTheme selectedTheme = AppTheme.system;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: ListView(
        children: [
          RadioListTile<AppTheme>(
            title: const Text('Light'),
            value: AppTheme.light,
            groupValue: selectedTheme,
            onChanged: (value) => setState(() => selectedTheme = value!),
          ),
          RadioListTile<AppTheme>(
            title: const Text('Dark'),
            value: AppTheme.dark,
            groupValue: selectedTheme,
            onChanged: (value) => setState(() => selectedTheme = value!),
          ),
          RadioListTile<AppTheme>(
            title: const Text('System Default'),
            value: AppTheme.system,
            groupValue: selectedTheme,
            onChanged: (value) => setState(() => selectedTheme = value!),
          ),
        ],
      ),
    );
  }
}

// ---------- Help & Support Screen with ExpansionTiles ----------
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> faqs = const [
    {
      'question': 'How do I reset my password?',
      'answer': 'You can reset your password in the Security settings.'
    },
    {
      'question': 'How do I contact support?',
      'answer': 'Please email support@example.com for assistance.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(faqs[index]['question']!),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(faqs[index]['answer']!),
              )
            ],
          );
        },
      ),
    );
  }
}

// ---------- Feedback Screen with a Text Field and Submit Button ----------
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController feedbackController = TextEditingController();

  void _submitFeedback() {
    // Placeholder for submitting feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback submitted')),
    );
    feedbackController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Your Feedback',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Logout Screen with a Confirmation Button ----------
class LogoutScreen extends StatelessWidget {
  const LogoutScreen({Key? key}) : super(key: key);

  void _confirmLogout(BuildContext context) {
    // Placeholder logout confirmation logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out')),
    );
    // Here you might navigate back to a login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logout')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _confirmLogout(context),
          child: const Text('Confirm Logout'),
        ),
      ),
    );
  }
}
