import 'package:flutter/material.dart';
import 'package:tower/theme/theme_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tower/screens/login/signup.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeNotifier(),
      builder: (context, currentMode, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF3E5F5), Colors.white, Color(0xFFE1F5FE)],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                "Settings",
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "General",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            // Notifications Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    activeColor: const Color(0xFF4C0B58),
                    title: const Text(
                      "Notifications",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C0B58),
                      ),
                    ),
                    subtitle: const Text("Receive updates and alerts"),
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    secondary: const Icon(
                      Icons.notifications_active,
                      color: Color(0xFF4C0B58),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.language,
                      color: Color(0xFF4C0B58),
                    ),
                    title: const Text(
                      "Language",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C0B58),
                      ),
                    ),
                    subtitle: const Text("English (US)"),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      _showLanguageDialog(context);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    activeColor: const Color(0xFF4C0B58),
                    title: const Text(
                      "Dark Mode",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C0B58),
                      ),
                    ),
                    value: ThemeNotifier().isDarkMode,
                    onChanged: (bool value) {
                      ThemeNotifier().toggleTheme();
                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value ? "Dark Mode Enabled" : "Dark Mode Disabled",
                          ),
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                    secondary: const Icon(
                      Icons.dark_mode,
                      color: Color(0xFF4C0B58),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 30),

          const Text(
            "Support & Legal",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {},
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.privacy_tip,
                  title: "Privacy Policy",
                  onTap: () {
                    _showDialog(
                      context,
                      "Privacy Policy",
                      "Privacy details...",
                    );
                  },
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.description,
                  title: "Terms of Service",
                  onTap: () {
                    _showDialog(
                      context,
                      "Terms of Service",
                      "Terms and conditions...",
                    );
                  },
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.info_outline,
                  title: "About App",
                  onTap: () {
                    _showDialog(
                      context,
                      "About Tower",
                      "Version 1.0.0\nDeveloped by Tower Team.",
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Delete Account Danger Zone
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => const DeleteAccountDialog(),
              );
            },
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text(
              "Delete Account",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
          ],
        ),
      ),

          ),
        );
      },
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("English (US)"),
                onTap: () {
                  Navigator.pop(context);
                  // Implement language change logic
                },
              ),
              ListTile(
                title: const Text("Tamil"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Spanish"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Simply returning ListTile inside the container from parent
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4C0B58).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF4C0B58)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF4C0B58),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete Account"),
      content: const Text(
        "Are you sure you want to delete your account? This action cannot be undone and all your data will be lost.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            // Delete logic
            try {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // Optional: Delete Firestore doc first
                await FirebaseFirestore.instance
                    .collection('employees')
                    .doc(user.uid)
                    .delete();
                await user.delete();

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateAccountScreen(),
                    ),
                    (route) => false,
                  );
                }
              }
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error deleting account: $e")),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Delete", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
