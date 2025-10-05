import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/models/account_model.dart';
import 'package:mobile_programming_uts/models/user_model.dart';
import 'package:mobile_programming_uts/widgets/balance_card.dart';
import 'package:mobile_programming_uts/widgets/action_button.dart';

class HomeTab extends StatelessWidget {
  final User user;
  final Account account;
  final VoidCallback? onAfterTransfer;

  const HomeTab({
    super.key,
    required this.user,
    required this.account,
    this.onAfterTransfer,
  });

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
            ActionButton(
              title: 'Transfer',
              icon: Icons.send,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/transfer',
                  arguments: account,
                ).then((_) => onAfterTransfer?.call());
              },
            ),
            const SizedBox(height: 8),
            ActionButton(
              title: 'Daftar Transfer',
              icon: Icons.account_balance,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/transfer_list',
                  arguments: account,
                ).then((_) => onAfterTransfer?.call());
              },
            ),
            const SizedBox(height: 8),
            ActionButton(
              title: 'Deposit & Withdraw',
              icon: Icons.account_balance_wallet,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/deposit_withdraw',
                  arguments: account,
                ).then((_) => onAfterTransfer?.call());
              },
            ),
            const SizedBox(height: 8),
            ActionButton(
              title: 'Tagihan & Pembayaran',
              icon: Icons.receipt_long,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/tagihan',
                  arguments: account,
                ).then((_) => onAfterTransfer?.call());
              },
            ),
          ],
        ),
      ),
    );
  }
}
