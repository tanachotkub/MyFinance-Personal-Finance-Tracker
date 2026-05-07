import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/transaction.dart';
import '../data/repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository();
  final Uuid _uuid = const Uuid();

  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  Map<String, double> _summary = {'income': 0, 'expense': 0, 'balance': 0};
  Map<String, double> get summary => _summary;

  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;
  int get currentYear => _currentYear;
  int get currentMonth => _currentMonth;

  Future<void> loadByMonth(int year, int month) async {
    _currentYear = year;
    _currentMonth = month;
    _transactions = await _repo.getByMonth(year, month);
    _summary = await _repo.getSummaryByMonth(year, month);
    notifyListeners();
  }

  Future<void> loadCurrentMonth() async {
    final now = DateTime.now();
    await loadByMonth(now.year, now.month);
  }

  Future<void> addTransaction({
    required double amount,
    required String type,
    required int categoryId,
    String? note,
    required String date,
  }) async {
    final transaction = Transaction(
      id: _uuid.v4(),
      amount: amount,
      type: type,
      categoryId: categoryId,
      note: note,
      date: date,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    await _repo.insert(transaction);

    // ← โหลดเดือนตาม date ที่บันทึก ไม่ใช่เดือนปัจจุบันเสมอ
    final parsedDate = DateTime.parse(date);
    await loadByMonth(parsedDate.year, parsedDate.month);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _repo.update(transaction);

    // ← โหลดเดือนตาม date ที่แก้ไข
    final parsedDate = DateTime.parse(transaction.date);
    await loadByMonth(parsedDate.year, parsedDate.month);
  }

  Future<void> deleteTransaction(String id) async {
    await _repo.delete(id);
    await loadByMonth(_currentYear, _currentMonth);
  }

  List<Map<String, dynamic>> _last6Months = [];
  List<Map<String, dynamic>> get last6Months => _last6Months;

  Future<void> loadLast6Months() async {
    _last6Months = await _repo.getLast6MonthsSummary();
    notifyListeners();
  }
}
