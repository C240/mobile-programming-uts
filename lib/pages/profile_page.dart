import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/models/user_model.dart';
import 'package:mobile_programming_uts/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile_programming_uts/pages/settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as User;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Pengaturan')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Username'),
            subtitle: Text(user.username),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('setting'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/settings', arguments: user);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Mode Gelap'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              final provider = Provider.of<ThemeProvider>(
                context,
                listen: false,
              );
              provider.toggleTheme(value);
            },
          ),
        ],
      ),
    );
  }
}
