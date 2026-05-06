import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/category_provider.dart';
import 'providers/transaction_provider.dart';

void main() {
  runApp(const MyFinanceApp());
}

class MyFinanceApp extends StatelessWidget {
  const MyFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'MyFinance',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const InitScreen(),
          );
        },
      ),
    );
  }
}

// โหลด data ก่อนเข้าแอป
class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final catProvider = context.read<CategoryProvider>();
    final txProvider  = context.read<TransactionProvider>();
    await catProvider.loadCategories();
    await txProvider.loadCurrentMonth();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Scaffold(
          body: Center(child: Text('✅ DB พร้อมแล้ว! ไปต่อ Dashboard')),
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}