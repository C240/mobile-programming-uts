import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_programming_uts/data/database_helper.dart';
import 'package:mobile_programming_uts/models/account_model.dart';
import 'package:mobile_programming_uts/models/transaction_model.dart';
import 'package:mobile_programming_uts/utils/format.dart';
import 'package:mobile_programming_uts/utils/category_utils.dart';
import 'package:mobile_programming_uts/widgets/category_avatar.dart';
import 'package:mobile_programming_uts/pages/tabs/history_tab.dart';

class InsightTab extends StatefulWidget {
  final Account account;
  const InsightTab({super.key, required this.account});

  @override
  State<InsightTab> createState() => _InsightTabState();
}

class _InsightTabState extends State<InsightTab>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  List<Transaction> _transactions = [];
  Map<DateTime, double> _weeklyOutgoing = {};
  Map<String, double> _categoryOutgoing = {};
  double _totalIncoming = 0;
  double _totalOutgoing = 0;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadInsights();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _loadInsights() async {
    final maps = await DatabaseHelper().getTransactions(
      widget.account.accountNumber,
    );
    final txs = maps.map((m) => Transaction.fromMap(m)).toList();
    setState(() {
      _transactions = txs;
    });
    _computeWeeklyOutgoing();
    _computeTotalsAndCategories();
    setState(() {
      _loading = false;
    });
  }

  void _computeWeeklyOutgoing() {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));
    final map = <DateTime, double>{};
    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      map[day] = 0.0;
    }
    for (final t in _transactions) {
      final tDay = DateTime(
        t.timestamp.year,
        t.timestamp.month,
        t.timestamp.day,
      );
      if (t.fromAccountNumber == widget.account.accountNumber &&
          map.containsKey(tDay)) {
        map[tDay] = (map[tDay] ?? 0) + t.amount;
      }
    }
    _weeklyOutgoing = map;
  }

  void _computeTotalsAndCategories() {
    double incoming = 0;
    double outgoing = 0;
    final cat = <String, double>{};
    for (final t in _transactions) {
      if (t.toAccountNumber == widget.account.accountNumber) {
        incoming += t.amount;
      }
      if (t.fromAccountNumber == widget.account.accountNumber) {
        outgoing += t.amount;
        final c = t.category ?? categorize(t.description);
        cat[c] = (cat[c] ?? 0) + t.amount;
      }
    }
    _totalIncoming = incoming;
    _totalOutgoing = outgoing;
    _categoryOutgoing = cat;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final maxWeekly = _weeklyOutgoing.values.isEmpty
        ? 0.0
        : _weeklyOutgoing.values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        // TabBar di atas
        Container(
          color: Theme.of(context).primaryColor.withOpacity(0.05),
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: "Transaksi"),
              Tab(text: "Promo Insight"),
            ],
          ),
        ),

        // Isi TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionInsight(maxWeekly),
              _buildPromoInsight(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionInsight(double maxWeekly) {
    return RefreshIndicator(
      onRefresh: _loadInsights,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildWeeklyCard(maxWeekly),
          const SizedBox(height: 16),
          _buildCategoryCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _summaryTile(
                  'Transaksi',
                  _transactions.length.toString(),
                  Icons.receipt_long,
                  Colors.blue,
                ),
                _summaryTile(
                  'Masuk',
                  formatRupiah(_totalIncoming),
                  Icons.call_received,
                  Colors.green,
                ),
                _summaryTile(
                  'Keluar',
                  formatRupiah(_totalOutgoing),
                  Icons.call_made,
                  Colors.red,
                ),
                _summaryTile(
                  'Net',
                  formatRupiah(_totalIncoming - _totalOutgoing),
                  Icons.calculate,
                  Colors.indigo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryTile(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildWeeklyCard(double maxWeekly) {
    final df = DateFormat('EEE');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mingguan (keluar)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weeklyOutgoing.entries.map((e) {
                final h = maxWeekly == 0
                    ? 4.0
                    : (e.value / maxWeekly * 60) + 4.0;
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: h,
                        width: 14,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        df.format(e.key),
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        formatRupiah(e.value),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard() {
    final items = _categoryOutgoing.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kategori Pengeluaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty) const Text('Belum ada data pengeluaran.'),
            for (final e in items)
              Builder(
                builder: (context) {
                  final color = colorForCategory(e.key);
                  final percent = _totalOutgoing == 0
                      ? 0.0
                      : (e.value / _totalOutgoing);
                  return ListTile(
                    dense: true,
                    leading: CategoryAvatar(category: e.key),
                    title: Text(e.key),
                    subtitle: LinearProgressIndicator(
                      value: percent.clamp(0.0, 1.0),
                      minHeight: 6,
                      color: color,
                      backgroundColor: color.withOpacity(0.15),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatRupiah(e.value),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${(percent * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(title: const Text('Riwayat')),
                            body: HistoryTab(
                              account: widget.account,
                              initialCategory: e.key,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoInsight() {
    final promos = [
      {
        'title': 'Cashback Oktober!',
        'desc': 'Dapatkan cashback 10% untuk transaksi di atas Rp100.000.',
        'color': Colors.green,
      },
      {
        'title': 'Gratis Biaya Admin',
        'desc': 'Transfer antar bank tanpa biaya admin setiap Jumat!',
        'color': Colors.orange,
      },
      {
        'title': 'Bonus Poin Belanja',
        'desc': 'Belanja pakai saldo dan kumpulkan poin reward!',
        'color': Colors.blue,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Promo Insight',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        for (var promo in promos)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: (promo['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.local_offer, color: promo['color'] as Color),
              title: Text(promo['title'] as String),
              subtitle: Text(promo['desc'] as String),
            ),
          ),
      ],
    );
  }
}
