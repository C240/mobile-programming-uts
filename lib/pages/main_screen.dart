import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/models/account_model.dart';
import 'package:mobile_programming_uts/models/user_model.dart';

// Import halaman-halaman yang akan menjadi Tab
import 'package:mobile_programming_uts/pages/tabs/home_tab.dart';
import 'package:mobile_programming_uts/pages/tabs/history_tab.dart';
import 'package:mobile_programming_uts/pages/tabs/profile_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  User? _user;
  Account? _account;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_user == null) {
      final userArgs = ModalRoute.of(context)!.settings.arguments as User;
      _user = userArgs;
      _loadAccountData(userArgs.id);
    }
  }

  void _loadAccountData(int userId) async {
    var accountMap = await DatabaseHelper().getAccount(userId);
    if (accountMap != null) {
      setState(() {
        _account = Account.fromMap(accountMap);
        // Inisialisasi daftar halaman setelah data user dan akun didapat
        _pages = [
          HomeTab(user: _user!, account: _account!),
          HistoryTab(account: _account!),
          ProfileTab(user: _user!),
        ];
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Index 1 adalah tombol 'Transfer'
      // Kita tidak mengganti tab, tapi membuka halaman baru
      Navigator.pushNamed(context, '/transfer', arguments: _account).then((_) {
        // Muat ulang data setelah kembali dari halaman transfer
        if (_user != null) {
          _loadAccountData(_user!.id);
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
  
  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading jika data belum siap
    if (_user == null || _account == null) {
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