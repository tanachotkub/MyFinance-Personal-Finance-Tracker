class Category {
  final int? id;
  final String name;
  final String type; // 'income' | 'expense'
  final String icon;
  final String color; // hex string เช่น 'FF6B6B'
  final bool isDefault;

  Category({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      icon: map['icon'],
      color: map['color'],
      isDefault: map['is_default'] == 1,
    );
  }
}