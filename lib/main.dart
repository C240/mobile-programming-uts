import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/pages/change_pin_page.dart';
import 'package:mobile_programming_uts/pages/login_page.dart';
import 'package:mobile_programming_uts/pages/main_screen.dart';
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
                title: 'C240 Bank',
                themeMode: themeProvider.themeMode,
                theme: ThemeData(
                  useMaterial3: true,
                  colorSchemeSeed: Colors.blue,
                  brightness: Brightness.light,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  colorSchemeSeed: Colors.blue,
                  brightness: Brightness.dark,
                ),
                initialRoute: '/',
                routes: {
                  '/': (context) => const LoginPage(),
                  '/register': (context) => const RegisterPage(),
                  '/main': (context) => const MainScreen(),
                  '/transfer': (context) => const TransferPage(),
                  '/transaction_detail': (context) => const TransactionDetailPage(),
                  '/change_pin': (context) => const ChangePinPage(),
                },
              );
            },
          ),
        );
      }
    }
    
