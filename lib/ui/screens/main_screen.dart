import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/page_transitions.dart';
import '../../providers/transaction_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'summary/monthly_summary_screen.dart';
import 'settings/settings_screen.dart';
import 'transactions/add_edit_transaction_screen.dart';
import 'budget/budget_screen.dart';
import '../../providers/budget_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MonthlySummaryScreen(),
    BudgetScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                final txProvider = context.read<TransactionProvider>();
                await Navigator.push(
                  context,
                  SlideUpRoute(page: const AddEditTransactionScreen()),
                );
                if (!mounted) {
                  return;
                }
                await txProvider.loadCurrentMonth();
              },
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('เพิ่มรายการ',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) async {
            setState(() => _currentIndex = index);
            if (!mounted) {
              return;
            }
            final txProvider = context.read<TransactionProvider>();
            final budgetProvider = context.read<BudgetProvider>(); // ← เพิ่ม
            await txProvider.loadCurrentMonth();
            await txProvider.loadLast6Months();
            await budgetProvider.loadBudgets(
              // ← เพิ่ม
              txProvider.currentYear,
              txProvider.currentMonth,
            );
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'หน้าแรก',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'สรุป',
            ),
            NavigationDestination(
              icon: Icon(Icons.wallet_outlined),
              selectedIcon: Icon(Icons.wallet),
              label: 'งบ',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'ตั้งค่า',
            ),
          ],
          indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}
