import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/models/account_model.dart';

class TransferListPage extends StatefulWidget {
  const TransferListPage({super.key});

  @override
  State<TransferListPage> createState() => _TransferListPageState();
}

class _TransferListPageState extends State<TransferListPage> {
  final List<Map<String, dynamic>> _transferTargets = [
    {
      'id': 1,
      'name': 'Budi Santoso',
      'bank': 'Bank BCA',
      'accountNumber': '0123456789',
    },
    {
      'id': 2,
      'name': 'Sinta Dewi',
      'bank': 'Bank Mandiri',
      'accountNumber': '1234567890',
    },
    {
      'id': 3,
      'name': 'Agus Pratama',
      'bank': 'Bank BNI',
      'accountNumber': '9876543210',
    },
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  /// Menampilkan dialog tambah tujuan baru
  void _showAddTargetDialog() {
    _nameController.clear();
    _bankController.clear();
    _accountController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tujuan Transfer'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Penerima',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _bankController,
                decoration: const InputDecoration(
                  labelText: 'Nama Bank',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nomor Rekening',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isEmpty ||
                  _bankController.text.isEmpty ||
                  _accountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua field harus diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setState(() {
                _transferTargets.add({
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'name': _nameController.text,
                  'bank': _bankController.text,
                  'accountNumber': _accountController.text,
                });
              });

              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Tujuan Transfer')),
      body: ListView.builder(
        itemCount: _transferTargets.length,
        itemBuilder: (context, index) {
          final target = _transferTargets[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(target['name']),
              subtitle: Text('${target['bank']} - ${target['accountNumber']}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Langsung menuju halaman transfer dan kirim data rekening tujuan
                Navigator.pushNamed(
                  context,
                  '/transfer',
                  arguments: Account(
                    id: target['id'],
                    userId: 0,
                    accountNumber: target['accountNumber'],
                    balance: 0,
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTargetDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tujuan'),
      ),
    );
  }
}
