import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/transaction_provider.dart';

class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
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
    final summary = txProvider.summary;
    final transactions = txProvider.transactions;
    final last6 = txProvider.last6Months;
    final categoryTotals = _groupByCategory(transactions);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'สรุป ${_months[txProvider.currentMonth]} ${txProvider.currentYear}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // สรุปรายรับรายจ่าย
          _buildSummaryRow(summary),
          const SizedBox(height: 24),

          // Bar Chart ย้อนหลัง 6 เดือน
          _buildSectionTitle('รายรับ-รายจ่าย ย้อนหลัง 6 เดือน'),
          const SizedBox(height: 12),
          _buildBarChart(last6),
          const SizedBox(height: 8),
          _buildBarChartLegend(),
          const SizedBox(height: 24),

          // Pie Chart
          if (categoryTotals.isNotEmpty) ...[
            _buildSectionTitle('สัดส่วนรายจ่ายตามหมวด'),
            const SizedBox(height: 12),
            _buildPieChart(categoryTotals),
            const SizedBox(height: 24),
          ],

          // Category List
          if (categoryTotals.isNotEmpty) ...[
            _buildSectionTitle('รายละเอียดตามหมวด'),
            const SizedBox(height: 12),
            _buildCategoryList(categoryTotals),
          ],

          if (transactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Text('📊', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('ไม่มีข้อมูลเดือนนี้',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(Map<String, double> summary) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'รายรับ',
            amount: '฿${fmt.format(summary['income'] ?? 0)}',
            color: AppTheme.incomeColor,
            icon: Icons.arrow_downward_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'รายจ่าย',
            amount: '฿${fmt.format(summary['expense'] ?? 0)}',
            color: AppTheme.expenseColor,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // หา max value เพื่อ scale กราฟ
    double maxVal = 1000;
    for (final d in data) {
      final inc = (d['income'] as num).toDouble();
      final exp = (d['expense'] as num).toDouble();
      if (inc > maxVal) {
        maxVal = inc;
      }
      if (exp > maxVal) {
        maxVal = exp;
      }
    }

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxVal * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  Theme.of(context).cardTheme.color ?? Colors.white,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final fmt = NumberFormat('#,##0', 'en_US');
                final label = rodIndex == 0 ? 'รายรับ' : 'รายจ่าย';
                return BarTooltipItem(
                  '$label\n฿${fmt.format(rod.toY)}',
                  TextStyle(
                    color: rodIndex == 0
                        ? AppTheme.incomeColor
                        : AppTheme.expenseColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox();
                  }
                  final month = data[index]['month'] as int;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _months[month],
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((e) {
            final index = e.key;
            final d = e.value;
            final income = (d['income'] as num).toDouble();
            final expense = (d['expense'] as num).toDouble();

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: income,
                  color: AppTheme.incomeColor,
                  width: 10,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: expense,
                  color: AppTheme.expenseColor,
                  width: 10,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
              barsSpace: 4,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBarChartLegend() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: AppTheme.incomeColor, label: 'รายรับ'),
        SizedBox(width: 20),
        _LegendDot(color: AppTheme.expenseColor, label: 'รายจ่าย'),
      ],
    );
  }

  Widget _buildPieChart(List<_CategoryTotal> data) {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sections: data.map((item) {
            return PieChartSectionData(
              value: item.total,
              title: item.icon,
              titleStyle: const TextStyle(fontSize: 18),
              color: item.color,
              radius: 80,
              titlePositionPercentageOffset: 0.6,
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<_CategoryTotal> data) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final total = data.fold(0.0, (sum, e) => sum + e.total);

    return Column(
      children: data.map((item) {
        final percent = total > 0 ? (item.total / total * 100) : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: item.color.withValues(alpha: 0.15),
                child: Text(item.icon, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text('฿${fmt.format(item.total)}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        backgroundColor: item.color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(item.color),
                        minHeight: 6,
                      ),
                    ),
                    Text(
                      '${percent.toStringAsFixed(1)}%',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<_CategoryTotal> _groupByCategory(List<Transaction> transactions) {
    final Map<int, _CategoryTotal> map = {};
    for (final t in transactions) {
      if (t.type != 'expense') {
        continue;
      }
      final id = t.categoryId;
      Color color = AppTheme.expenseColor;
      try {
        if (t.categoryColor != null) {
          color = Color(int.parse('FF${t.categoryColor}', radix: 16));
        }
      } catch (_) {}

      if (map.containsKey(id)) {
        map[id] = _CategoryTotal(
          id: id,
          name: map[id]!.name,
          icon: map[id]!.icon,
          color: map[id]!.color,
          total: map[id]!.total + t.amount,
        );
      } else {
        map[id] = _CategoryTotal(
          id: id,
          name: t.categoryName ?? 'ไม่ระบุ',
          icon: t.categoryIcon ?? '💰',
          color: color,
          total: t.amount,
        );
      }
    }
    final list = map.values.toList();
    list.sort((a, b) => b.total.compareTo(a.total));
    return list;
  }
}

// Helper classes
class _CategoryTotal {
  final int id;
  final String name;
  final String icon;
  final Color color;
  final double total;

  const _CategoryTotal({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.total,
  });
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(label, style: TextStyle(color: color, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
