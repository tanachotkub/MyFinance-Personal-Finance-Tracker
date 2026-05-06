import 'package:flutter/material.dart';
import '../data/models/category.dart';
import '../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  List<Category> get incomeCategories =>
      _categories.where((c) => c.type == 'income').toList();

  List<Category> get expenseCategories =>
      _categories.where((c) => c.type == 'expense').toList();

  Future<void> loadCategories() async {
    _categories = await _repo.getAll();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await _repo.insert(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _repo.delete(id);
    await loadCategories();
  }
}