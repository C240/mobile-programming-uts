import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/models/account_model.dart';
import 'package:mobile_programming_uts/models/user_model.dart';

// Import halaman-halaman yang akan menjadi Tab
import 'package:mobile_programming_uts/pages/tabs/home_tab.dart';
import 'package:mobile_programming_uts/pages/tabs/history_tab.dart';
import 'package:mobile_programming_uts/pages/tabs/profile_tab.dart';
import 'package:mobile_programming_uts/utils/format.dart';

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
          HomeTab(user: _user!, account: _selectedAccount!),
          HistoryTab(account: _selectedAccount!),
          ProfileTab(user: _user!),
        ];
      });
      // Seed akun kedua untuk demo multi-akun jika baru ada satu akun
      if (accounts.length == 1) {
        await DatabaseHelper().createAccount(userId, 250000.0);
        final refreshed = await DatabaseHelper().getAccounts(userId);
        final refreshedAccounts = refreshed.map((m) => Account.fromMap(m)).toList();
        setState(() {
          _accounts = refreshedAccounts;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Index 1 adalah tombol 'Transfer'
      // Kita tidak mengganti tab, tapi membuka halaman baru
      Navigator.pushNamed(context, '/transfer', arguments: _selectedAccount).then((_) {
        // Muat ulang data setelah kembali dari halaman transfer
        if (_user != null) {
          _loadAccounts(_user!.id);
        }
      });
    } else {
      // Untuk Beranda, Riwayat, dan Profil, kita ganti tab
      setState(() {
        // Sesuaikan index karena 'Transfer' bukan tab
        _selectedIndex = index > 1 ? index -1 : index;
      });
    }
  }

  void _onSelectAccount(Account account) {
    setState(() {
      _selectedAccount = account;
      _pages = [
        HomeTab(user: _user!, account: _selectedAccount!),
        HistoryTab(account: _selectedAccount!),
        ProfileTab(user: _user!),
      ];
    });
  }
  
  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading jika data belum siap
    if (_user == null || _selectedAccount == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)),
        actions: [
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: 'Transfer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        // Logika untuk highlight item yang benar
        currentIndex: _selectedIndex >= 1 ? _selectedIndex + 1 : _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Beranda';
      case 1:
        return 'Riwayat Transaksi';
      case 2:
        return 'Profil';
      default:
        return 'Mobile Banking';
    }
  }
}