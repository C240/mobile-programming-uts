    import 'package:flutter/material.dart';
    import 'package:mobile_programming_uts/models/account_model.dart';
    import 'package:mobile_programming_uts/models/user_model.dart';
    import 'package:mobile_programming_uts/widgets/balance_card.dart';

    class HomeTab extends StatelessWidget {
      final User user;
      final Account account;

      const HomeTab({super.key, required this.user, required this.account});

      @override
      Widget build(BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang, ${user.username}!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                BalanceCard(account: account),
                const SizedBox(height: 32),
                const Text(
                  "Fitur Utama",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                 const SizedBox(height: 16),
                // Anda bisa menambahkan tombol-tombol lain di sini jika perlu
                // Tombol Transfer & Riwayat sekarang ada di Bottom Navigation
              ],
            ),
          ),
        );
      }
    }
    
