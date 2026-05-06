import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/transaction_card.dart';
import '../transactions/add_edit_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<String> _months = [
    '',
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.'
  ];
  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final summary = txProvider.summary;
    final transactions = txProvider.transactions;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: GestureDetector(
            onTap: _pickMonth,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_months[txProvider.currentMonth]} ${txProvider.currentYear}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                  themeProvider.isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: themeProvider.toggleTheme,
            ),
          ],
          floating: true,
          snap: true,
          elevation: 0,
        ),
        SliverToBoxAdapter(
          child: BalanceCard(
            income: summary['income'] ?? 0,
            expense: summary['expense'] ?? 0,
            balance: summary['balance'] ?? 0,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'รายการล่าสุด',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${transactions.length} รายการ',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        transactions.isEmpty
            ? SliverToBoxAdapter(child: _buildEmpty())
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => TransactionCard(
                    transaction: transactions[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditTransactionScreen(
                          transaction: transactions[index],
                        ),
                      ),
                    ),
                    onDelete: () => _confirmDelete(transactions[index].id),
                  ),
                  childCount: transactions.length,
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Text('💸', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('ยังไม่มีรายการเดือนนี้', style: TextStyle(color: Colors.grey)),
          Text('กด + เพื่อเพิ่มรายการแรก',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _pickMonth() async {
    final txProvider = context.read<TransactionProvider>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(txProvider.currentYear, txProvider.currentMonth),
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year, now.month),
      helpText: 'เลือกเดือน',
    );
    if (picked != null) {
      await txProvider.loadByMonth(picked.year, picked.month);
    }
  }

  Future<void> _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ลบรายการ'),
        content: const Text('ต้องการลบรายการนี้ใช่ไหม?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<TransactionProvider>().deleteTransaction(id);
    }
  }

}
