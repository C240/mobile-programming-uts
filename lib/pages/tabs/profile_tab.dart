    import 'package:flutter/material.dart';
    import 'package:mobile_programming_uts/models/user_model.dart';
    import 'package:mobile_programming_uts/providers/theme_provider.dart';
    import 'package:provider/provider.dart';

    class ProfileTab extends StatelessWidget {
      final User user;
      const ProfileTab({super.key, required this.user});

      @override
      Widget build(BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        return ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Username'),
              subtitle: Text(user.username),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Ubah PIN'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/change_pin', arguments: user);
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Mode Gelap'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                final provider = Provider.of<ThemeProvider>(context, listen: false);
                provider.toggleTheme(value);
              },
            ),
          ],
        );
      }
    }
    
