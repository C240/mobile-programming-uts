// lib/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/models/account_model.dart';
import 'package:mobile_programming_uts/models/user_model.dart';
import 'package:mobile_programming_uts/widgets/action_button.dart'; // Import widget baru
import 'package:mobile_programming_uts/widgets/balance_card.dart';  // Import widget baru

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Account? _account;
  User? _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_user == null) {
      final userArgs = ModalRoute.of(context)!.settings.arguments as User;
      setState(() {
        _user = userArgs;
      });
      _loadAccountData(userArgs.id);
    }
  }

  void _loadAccountData(int userId) async {
    var accountMap = await DatabaseHelper().getAccount(userId);
    if (accountMap != null) {
      setState(() {
        _account = Account.fromMap(accountMap);
      });
    }
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang, ${_user!.username}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Menggunakan BalanceCard Widget
            BalanceCard(account: _account),
            
            const SizedBox(height: 32),
            
            // Menggunakan ActionButton Widget untuk Transfer
            ActionButton(
              title: 'Transfer',
              icon: Icons.send,
              onPressed: () {
                Navigator.pushNamed(context, '/transfer', arguments: _account)
                    .then((_) {
                  if (_user != null) {
                    _loadAccountData(_user!.id);
                  }
                });
              },
            ),

            const SizedBox(height: 16),

            // Menggunakan ActionButton Widget untuk Riwayat
            ActionButton(
              title: 'Riwayat Transaksi',
              icon: Icons.history,
              onPressed: () {
                Navigator.pushNamed(context, '/history', arguments: _account);
              },
            ),
          ],
        ),
      ),
    );
  }
}