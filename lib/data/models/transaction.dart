class Transaction {
  final String id; // UUID
  final double amount;
  final String type; // 'income' | 'expense'
  final int categoryId;
  final String? note;
  final String date; // yyyy-MM-dd
  final String createdAt;

  // join กับ category (ไม่ได้เก็บใน DB)
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.note,
    required this.date,
    required this.createdAt,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'note': note,
      'date': date,
      'created_at': createdAt,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      categoryId: map['category_id'],
      note: map['note'],
      date: map['date'],
      createdAt: map['created_at'],
      categoryName: map['category_name'],
      categoryIcon: map['category_icon'],
      categoryColor: map['category_color'],
    );
  }

  Transaction copyWith({
    String? id,
    double? amount,
    String? type,
    int? categoryId,
    String? note,
    String? date,
    String? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}