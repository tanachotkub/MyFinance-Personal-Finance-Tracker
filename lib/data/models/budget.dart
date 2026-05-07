class Budget {
  final int? id;
  final int categoryId;
  final double amount;

  // join กับ category
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;

  // คำนวณจาก transactions
  final double spent;

  Budget({
    this.id,
    required this.categoryId,
    required this.amount,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.spent = 0,
  });

  double get remaining => amount - spent;
  double get percentage => amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0;
  bool get isOverBudget => spent > amount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categoryId: map['category_id'],
      amount: map['amount'],
      categoryName: map['category_name'],
      categoryIcon: map['category_icon'],
      categoryColor: map['category_color'],
      spent: map['spent'] ?? 0,
    );
  }

  Budget copyWith({double? amount, double? spent}) {
    return Budget(
      id: id,
      categoryId: categoryId,
      amount: amount ?? this.amount,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
      spent: spent ?? this.spent,
    );
  }
}