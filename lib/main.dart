    import 'package:flutter/material.dart';
    import 'package:mobile_programming_uts/pages/change_pin_page.dart';
    import 'package:mobile_programming_uts/pages/login_page.dart';
    import 'package:mobile_programming_uts/pages/main_screen.dart'; // Import baru
    import 'package:mobile_programming_uts/pages/register_page.dart';
    import 'package:mobile_programming_uts/pages/transaction_detail_page.dart';
    import 'package:mobile_programming_uts/pages/transfer_page.dart';
    import 'package:mobile_programming_uts/providers/theme_provider.dart';
    import 'package:provider/provider.dart';

    void main() {
      runApp(const MyApp());
    }

    class MyApp extends StatelessWidget {
      const MyApp({super.key});

      @override
      Widget build(BuildContext context) {
        return ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'Mobile Banking UTS',
                themeMode: themeProvider.themeMode,
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  brightness: Brightness.light,
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  primarySwatch: Colors.blue,
                ),
                initialRoute: '/',
                routes: {
                  '/': (context) => const LoginPage(),
                  '/register': (context) => const RegisterPage(),
                  '/main': (context) => const MainScreen(), // Rute utama baru
                  '/transfer': (context) => const TransferPage(),
                  '/transaction_detail': (context) => const TransactionDetailPage(),
                  '/change_pin': (context) => const ChangePinPage(),
                  // Hapus '/dashboard', '/history', dan '/profile' karena sudah menjadi bagian dari MainScreen
                },
              );
            },
          ),
        );
      }
    }
    
