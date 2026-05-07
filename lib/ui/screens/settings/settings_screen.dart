import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/export_repository.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../core/utils/page_transitions.dart'; // ← เพิ่ม
import 'category_screen.dart'; // ← เพิ่ม

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่า',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSection('ธีม', [
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              subtitle: const Text('สลับธีมมืด/สว่าง'),
              value: themeProvider.isDark,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ]),
          _buildSection('ข้อมูล', [
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Export เดือนนี้ (CSV)'),
              subtitle: const Text('ส่งออกรายการเดือนปัจจุบัน'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _export(context, currentMonthOnly: true),
            ),
            ListTile(
              leading: const Icon(Icons.download_for_offline_outlined),
              title: const Text('Export ทั้งหมด (CSV)'),
              subtitle: const Text('ส่งออกรายการทุกเดือน'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _export(context, currentMonthOnly: false),
            ),
          ]),
          _buildSection('หมวดหมู่', [
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('จัดการหมวดหมู่'),
              subtitle: const Text('เพิ่ม/ลบหมวดรายรับ-รายจ่าย'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                SlideUpRoute(page: const CategoryScreen()),
              ),
            ),
          ]),
          _buildSection('เกี่ยวกับ', [
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('MyFinance'),
              subtitle: Text('v1.0.0 — Personal Finance Tracker'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Future<void> _export(BuildContext context,
      {required bool currentMonthOnly}) async {
    final txProvider = context.read<TransactionProvider>();

    // แสดง loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = ExportRepository();
      if (currentMonthOnly) {
        await repo.exportToCsv(
          year: txProvider.currentYear,
          month: txProvider.currentMonth,
        );
      } else {
        await repo.exportToCsv();
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export ไม่สำเร็จ: $e')),
      );
    } finally {
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
