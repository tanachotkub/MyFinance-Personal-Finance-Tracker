import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;

  const BalanceCard({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.4), // ← เปลี่ยน
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ยอดคงเหลือเดือนนี้',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '฿${fmt.format(balance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _SummaryItem(
                label: 'รายรับ',
                amount: income,
                icon: Icons.arrow_downward_rounded,
                color: AppTheme.incomeColor,
              )),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                  child: _SummaryItem(
                label: 'รายจ่าย',
                amount: expense,
                icon: Icons.arrow_upward_rounded,
                color: AppTheme.expenseColor,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '฿${fmt.format(amount)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
