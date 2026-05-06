import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import 'transaction_repository.dart';

class ExportRepository {
  final TransactionRepository _txRepo = TransactionRepository();

  Future<void> exportToCsv({int? year, int? month}) async {
    // ดึงข้อมูล
    List<Transaction> transactions;
    if (year != null && month != null) {
      transactions = await _txRepo.getByMonth(year, month);
    } else {
      transactions = await _txRepo.getAll();
    }

    // สร้าง CSV rows
    final List<List<dynamic>> rows = [
      // Header
      ['วันที่', 'ประเภท', 'หมวดหมู่', 'จำนวนเงิน', 'โน้ต'],
      // Data
      ...transactions.map((t) => [
            t.date,
            t.type == 'income' ? 'รายรับ' : 'รายจ่าย',
            t.categoryName ?? '',
            t.amount,
            t.note ?? '',
          ]),
    ];

    // แปลงเป็น CSV string
    final csv = const ListToCsvConverter().convert(rows);

    // บันทึกไฟล์
    final dir = await getTemporaryDirectory();
    final fileName = month != null
        ? 'myfinance_${year}_${month.toString().padLeft(2, '0')}.csv'
        : 'myfinance_all.csv';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csv);

    // แชร์ไฟล์
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'MyFinance Export - $fileName',
    );
  }
}