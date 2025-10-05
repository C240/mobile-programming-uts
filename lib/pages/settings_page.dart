import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/models/user_model.dart';
import 'package:mobile_programming_uts/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  final User user;

  const SettingsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan Aplikasi"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Bagian Informasi Pengguna ---
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user.username),
              subtitle: const Text("Profil Pengguna"),
            ),
          ),
          const SizedBox(height: 20),

          // --- Tema / Mode Gelap ---
          SwitchListTile(
            title: const Text("Mode Gelap"),
            subtitle: const Text("Aktifkan tampilan tema gelap"),
            value: themeProvider.isDarkMode,
            secondary: const Icon(Icons.dark_mode),
            onChanged: (val) {
              Provider.of<ThemeProvider>(
                context,
                listen: false,
              ).toggleTheme(val);
            },
          ),
          const Divider(),

          // --- Notifikasi ---
          SwitchListTile(
            title: const Text("Notifikasi"),
            subtitle: const Text("Aktifkan pemberitahuan transaksi"),
            value: true,
            secondary: const Icon(Icons.notifications),
            onChanged: (val) {
              // simulasi, nanti bisa disimpan di shared preferences
            },
          ),
          const Divider(),

          // --- Bahasa ---
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Bahasa"),
            subtitle: const Text("Indonesia"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // nanti bisa diarahkan ke halaman pilihan bahasa
            },
          ),
          const Divider(),

          // --- Keamanan ---
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Ubah PIN"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/change_pin', arguments: user);
            },
          ),
          const Divider(),

          // --- Tentang Aplikasi ---
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("Tentang Aplikasi"),
            subtitle: const Text("Versi 1.0.0"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "C240 Bank",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(Icons.account_balance),
                children: const [
                  Text(
                    "Aplikasi Mobile Banking Sederhana untuk mata kuliah Mobile Programming.",
                  ),
                ],
              );
            },
          ),
          const Divider(),

          // --- Logout ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Keluar"),
            textColor: Colors.red,
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
