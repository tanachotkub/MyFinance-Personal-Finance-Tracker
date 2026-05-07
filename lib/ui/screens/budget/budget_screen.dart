import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/transaction_provider.dart';

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

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // หัว
                        Row(
                          children: [
                            Text(budget.categoryIcon ?? '💰',
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                budget.categoryName ?? 'ไม่ระบุ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit_outlined,
                                  color: Colors.grey[400], size: 20),
                              onPressed: () => _showEditBudgetDialog(
                                  budget.categoryId, budget.amount),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: Colors.grey[400], size: 20),
                              onPressed: () => _deleteBudget(budget.categoryId),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: budget.percentage,
                            backgroundColor:
                                progressColor.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation(progressColor),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ตัวเลข
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
                                  ? '⚠️ เกินงบ ฿${fmt.format(budget.spent - budget.amount)}'
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
                          'งบทั้งหมด ฿${fmt.format(budget.amount)} • ${(budget.percentage * 100).toStringAsFixed(0)}%',
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
    Category? selected = categories.isNotEmpty ? categories.first : null;
    final amountController = TextEditingController(
      text: initialAmount != null ? initialAmount.toStringAsFixed(0) : '',
    );

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'แก้ไขงบประมาณ' : 'ตั้งงบประมาณ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEdit)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<Category>(
                    value: selected,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Row(
                                children: [
                                  Text(c.icon),
                                  const SizedBox(width: 8),
                                  Text(c.name),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selected = v),
                  ),
                ),
              if (!isEdit) const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'งบประมาณ (฿)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixText: '฿ ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0 || selected == null) {
                  return;
                }
                final budgetProvider = context.read<BudgetProvider>();
                final txProvider = context.read<TransactionProvider>();
                await budgetProvider.setBudget(selected!.id!, amount);
                await budgetProvider.loadBudgets(
                    txProvider.currentYear, txProvider.currentMonth);
                if (!context.mounted) {
                  return;
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
    amountController.dispose();
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
