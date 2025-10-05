import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/models/account_model.dart';
import 'package:mobile_programming_uts/models/user_model.dart';

import 'package:mobile_programming_uts/pages/tabs/home_tab.dart';
import 'package:mobile_programming_uts/pages/tabs/history_tab.dart';
import 'package:mobile_programming_uts/pages/tabs/insight_tab.dart';
import 'package:mobile_programming_uts/pages/tabs/profile_tab.dart';
import 'package:mobile_programming_uts/pages/settings_page.dart';
import 'package:mobile_programming_uts/utils/format.dart';
import 'package:mobile_programming_uts/utils/branding.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  User? _user;
  List<Account> _accounts = [];
  Account? _selectedAccount;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_user == null) {
      final userArgs = ModalRoute.of(context)!.settings.arguments as User;
      _user = userArgs;
      _loadAccounts(userArgs.id);
    }
  }

  void _loadAccounts(int userId) async {
    final accountsMap = await DatabaseHelper().getAccounts(userId);
    if (accountsMap.isNotEmpty) {
      final accounts = accountsMap.map((m) => Account.fromMap(m)).toList();
      setState(() {
        _accounts = accounts;
        _selectedAccount = _selectedAccount ?? accounts.first;
        _pages = [
          HomeTab(
            user: _user!,
            account: _selectedAccount!,
            onAfterTransfer: () => _loadAccounts(_user!.id),
          ),
          HistoryTab(account: _selectedAccount!),
          InsightTab(account: _selectedAccount!),
          ProfileTab(user: _user!),
        ];
      });

      // Auto-create account jika cuma 1
      if (accounts.length == 1) {
        await DatabaseHelper().createAccount(userId, 250000.0);
        final refreshed = await DatabaseHelper().getAccounts(userId);
        final refreshedAccounts = refreshed
            .map((m) => Account.fromMap(m))
            .toList();
        setState(() {
          _accounts = refreshedAccounts;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onSelectAccount(Account account) {
    setState(() {
      _selectedAccount = account;
      _pages = [
        HomeTab(
          user: _user!,
          account: _selectedAccount!,
          onAfterTransfer: () => _loadAccounts(_user!.id),
        ),
        HistoryTab(account: _selectedAccount!),
        InsightTab(account: _selectedAccount!),
        ProfileTab(user: _user!),
      ];
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage(user: _user!)),
    );
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null || _selectedAccount == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.account_balance, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$appName • ${_getAppBarTitle(_selectedIndex)}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
            ), // ⚙️ Tombol pengaturan di pojok kanan atas
            tooltip: 'Pengaturan',
            onPressed: _openSettings,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
          if (_accounts.isNotEmpty)
            PopupMenuButton<Account>(
              icon: const Icon(Icons.account_balance_wallet),
              tooltip: 'Pilih Akun',
              onSelected: _onSelectAccount,
              itemBuilder: (context) {
                return _accounts.map((acc) {
                  return PopupMenuItem<Account>(
                    value: acc,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text(acc.accountNumber)),
                        const SizedBox(width: 12),
                        Text(formatRupiah(acc.balance)),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Insight'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Beranda';
      case 1:
        return 'Transaksi';
      case 2:
        return 'Insight';
      case 3:
        return 'Profil';
      default:
        return 'Mobile Banking';
    }
  }
}
