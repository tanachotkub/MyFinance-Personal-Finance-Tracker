import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final isIncome = transaction.type == 'income';
    final amountColor = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
    final amountText =
        '${isIncome ? '+' : '-'}฿${fmt.format(transaction.amount)}';

    // แปลง hex color string เป็น Color
    Color categoryColor = AppTheme.primaryColor;
    try {
      if (transaction.categoryColor != null) {
        categoryColor =
            Color(int.parse('FF${transaction.categoryColor}', radix: 16));
      }
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: categoryColor.withValues(alpha: 0.15), // ← เปลี่ยน
          child: Text(transaction.categoryIcon ?? '💰',
              style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          transaction.categoryName ?? 'ไม่ระบุ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          transaction.note?.isNotEmpty == true
              ? transaction.note!
              : transaction.date,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amountText,
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.delete_outline,
                    color: Colors.grey[400], size: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
