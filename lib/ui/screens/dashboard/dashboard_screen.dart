import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/category_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/transaction_card.dart';
import '../transactions/add_edit_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final summary = txProvider.summary;
    final transactions = txProvider.filteredTransactions;

    return CustomScrollView(
      slivers: [
        // AppBar
        SliverAppBar(
          floating: true,
          snap: true,
          elevation: 0,
          title: _showSearch
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'ค้นหารายการ...',
                    border: InputBorder.none,
                  ),
                  onChanged: txProvider.setSearchQuery,
                )
              : GestureDetector(
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
              icon: Icon(_showSearch ? Icons.close : Icons.search),
              onPressed: () {
                setState(() => _showSearch = !_showSearch);
                if (!_showSearch) {
                  _searchController.clear();
                  txProvider.setSearchQuery('');
                }
              },
            ),
            IconButton(
              icon: Stack(
                children: [
                  Icon(themeProvider.isDark
                      ? Icons.light_mode
                      : Icons.dark_mode),
                  if (txProvider.hasActiveFilter)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: themeProvider.toggleTheme,
            ),
          ],
        ),

        // Balance Card
        SliverToBoxAdapter(
          child: BalanceCard(
            income: summary['income'] ?? 0,
            expense: summary['expense'] ?? 0,
            balance: summary['balance'] ?? 0,
          ),
        ),

        // Filter Chips
        SliverToBoxAdapter(
          child: _buildFilterChips(txProvider),
        ),

        // Header รายการ
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'รายการ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      '${transactions.length} รายการ',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    if (txProvider.hasActiveFilter) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          txProvider.clearFilters();
                          _searchController.clear();
                          setState(() => _showSearch = false);
                        },
                        child: const Text(
                          'ล้างตัวกรอง',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        // Transaction List
        transactions.isEmpty
            ? SliverToBoxAdapter(child: _buildEmpty(txProvider.hasActiveFilter))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => TransactionCard(
                    transaction: transactions[index],
                    onTap: () async {
                      final txProv = context.read<TransactionProvider>();
                      await Navigator.push(
                        context,
                        SlideUpRoute(
                          page: AddEditTransactionScreen(
                            transaction: transactions[index],
                          ),
                        ),
                      );
                      if (!mounted) {
                        return;
                      }
                      await txProv.loadCurrentMonth();
                    },
                    onDelete: () => _confirmDelete(transactions[index].id),
                  ),
                  childCount: transactions.length,
                ),
              ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildFilterChips(TransactionProvider txProvider) {
    final categories = context.read<CategoryProvider>().categories;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Filter ตาม type
          _FilterChip(
            label: 'ทั้งหมด',
            selected: txProvider.filterType == 'all',
            onTap: () => txProvider.setFilterType('all'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '💰 รายรับ',
            selected: txProvider.filterType == 'income',
            color: AppTheme.incomeColor,
            onTap: () => txProvider.setFilterType('income'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '💸 รายจ่าย',
            selected: txProvider.filterType == 'expense',
            color: AppTheme.expenseColor,
            onTap: () => txProvider.setFilterType('expense'),
          ),
          const SizedBox(width: 8),

          // Divider
          Container(width: 1, height: 24, color: Colors.grey[300]),
          const SizedBox(width: 8),

          // Filter ตาม category
          ...categories.map((cat) {
            final isSelected = txProvider.filterCategoryId == cat.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: '${cat.icon} ${cat.name}',
                selected: isSelected,
                onTap: () => txProvider.setFilterCategory(
                  isSelected ? null : cat.id,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool hasFilter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Text(hasFilter ? '🔍' : '💸', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            hasFilter ? 'ไม่พบรายการที่ค้นหา' : 'ยังไม่มีรายการเดือนนี้',
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            hasFilter
                ? 'ลองเปลี่ยนคำค้นหาหรือล้างตัวกรอง'
                : 'กด + เพื่อเพิ่มรายการแรก',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
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
            child: const Text('ยกเลิก'),
          ),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppTheme.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.12)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? activeColor : Colors.grey[600],
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
