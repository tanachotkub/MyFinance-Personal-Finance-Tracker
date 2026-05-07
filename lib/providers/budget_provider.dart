import 'package:flutter/material.dart';
import '../data/models/budget.dart';
import '../data/repositories/budget_repository.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _repo = BudgetRepository();

  List<Budget> _budgets = [];
  List<Budget> get budgets => _budgets;

  List<Budget> get overBudgets =>
      _budgets.where((b) => b.isOverBudget).toList();

  Future<void> loadBudgets(int year, int month) async {
    _budgets = await _repo.getBudgetsWithSpent(year, month);
    notifyListeners();
  }

  Future<void> setBudget(int categoryId, double amount) async {
    await _repo.setBudget(categoryId, amount);
    notifyListeners();
  }

  Future<void> deleteBudget(int categoryId) async {
    await _repo.deleteBudget(categoryId);
    _budgets.removeWhere((b) => b.categoryId == categoryId);
    notifyListeners();
  }
}