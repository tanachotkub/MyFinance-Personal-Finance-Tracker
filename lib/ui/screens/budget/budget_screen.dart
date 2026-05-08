import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/transaction_provider.dart';
import 'budget_dialog.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final txProvider = context.read<TransactionProvider>();
    await context.read<BudgetProvider>().loadBudgets(
          txProvider.currentYear,
          txProvider.currentMonth,
        );
  }

  @override
  Widget build(BuildContext context) {
    final budgets = context.watch<BudgetProvider>().budgets;
    final fmt = NumberFormat('#,##0.00', 'en_US');

    return Scaffold(
      appBar: AppBar(
        title: const Text('งบประมาณ',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddBudgetDialog,
            tooltip: 'เพิ่มงบ',
          ),
        ],
      ),
      body: budgets.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                Color catColor = AppTheme.primaryColor;
                try {
                  if (budget.categoryColor != null) {
                    catColor = Color(
                        int.parse('FF${budget.categoryColor}', radix: 16));
                  }
                } catch (_) {}

                final isOver = budget.isOverBudget;
                final progressColor = isOver ? AppTheme.expenseColor : catColor;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    border: isOver
                        ? Border.all(
                            color: AppTheme.expenseColor.withValues(alpha: 0.4),
                            width: 1.5)
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(budget.categoryIcon ?? '💰',
                                    style: const TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    budget.categoryName ?? 'ไม่ระบุ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    'งบ ฿${fmt.format(budget.amount)}',
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            if (isOver)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.expenseColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('⚠️ เกินงบ',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.expenseColor)),
                              ),
                            IconButton(
                              icon: Icon(Icons.edit_outlined,
                                  color: Colors.grey[400], size: 18),
                              onPressed: () => _showEditBudgetDialog(
                                  budget.categoryId, budget.amount),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: Colors.grey[400], size: 18),
                              onPressed: () => _deleteBudget(budget.categoryId),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: budget.percentage,
                            backgroundColor:
                                progressColor.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation(progressColor),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ใช้ไป ฿${fmt.format(budget.spent)}',
                              style: TextStyle(
                                color: progressColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              isOver
                                  ? 'เกิน ฿${fmt.format(budget.spent - budget.amount)}'
                                  : 'เหลือ ฿${fmt.format(budget.remaining)}',
                              style: TextStyle(
                                color: isOver
                                    ? AppTheme.expenseColor
                                    : Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(budget.percentage * 100).toStringAsFixed(0)}% ของงบทั้งหมด',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💰', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          const Text('ยังไม่มีงบประมาณ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('กด + เพื่อตั้งงบแต่ละหมวด',
              style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddBudgetDialog,
            icon: const Icon(Icons.add),
            label: const Text('เพิ่มงบประมาณ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddBudgetDialog() async {
    final categories = context.read<CategoryProvider>().expenseCategories;
    final budgets = context.read<BudgetProvider>().budgets;
    final usedIds = budgets.map((b) => b.categoryId).toSet();
    final available = categories.where((c) => !usedIds.contains(c.id)).toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ตั้งงบครบทุกหมวดแล้ว')),
      );
      return;
    }

    await _showBudgetDialog(categories: available);
  }

  Future<void> _showEditBudgetDialog(
      int categoryId, double currentAmount) async {
    final categories = context.read<CategoryProvider>().expenseCategories;
    final cat = categories.where((c) => c.id == categoryId).toList();
    await _showBudgetDialog(
        categories: cat, initialAmount: currentAmount, isEdit: true);
  }

Future<void> _showBudgetDialog({
  required List<Category> categories,
  double? initialAmount,
  bool isEdit = false,
}) async {
  if (!mounted) { return; }
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BudgetBottomSheet(
      categories: categories,
      initialAmount: initialAmount,
      isEdit: isEdit,
    ),
  );
}

  Future<void> _deleteBudget(int categoryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ลบงบประมาณ'),
        content: const Text('ต้องการลบงบประมาณหมวดนี้ใช่ไหม?'),
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
      await context.read<BudgetProvider>().deleteBudget(categoryId);
    }
  }
}
