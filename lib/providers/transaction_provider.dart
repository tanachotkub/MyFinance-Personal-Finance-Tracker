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
      createdAt: DateTime.now().toIso8601String(),
    );
    await _repo.insert(transaction);
    await loadByMonth(_currentYear, _currentMonth);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _repo.update(transaction);
    await loadByMonth(_currentYear, _currentMonth);
  }

  Future<void> deleteTransaction(String id) async {
    await _repo.delete(id);
    await loadByMonth(_currentYear, _currentMonth);
  }
}