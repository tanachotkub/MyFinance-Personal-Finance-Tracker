import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category.dart';
import '../../../providers/category_provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Emoji ให้เลือก
  static const List<String> _icons = [
    '🍜',
    '🍕',
    '🍔',
    '🥗',
    '☕',
    '🍱',
    '🥤',
    '🍣',
    '🚗',
    '🚌',
    '✈️',
    '🚂',
    '⛽',
    '🛵',
    '🚕',
    '🚲',
    '🛍️',
    '👗',
    '👟',
    '💄',
    '🎁',
    '🧴',
    '👔',
    '💍',
    '🏠',
    '🔑',
    '💡',
    '🚿',
    '🛋️',
    '🧹',
    '🏡',
    '🔧',
    '💊',
    '🏥',
    '🏃',
    '💪',
    '🧘',
    '⚕️',
    '🩺',
    '💉',
    '🎮',
    '🎬',
    '🎵',
    '📚',
    '🎲',
    '🎯',
    '🏆',
    '🎨',
    '💼',
    '💰',
    '📈',
    '🏦',
    '💳',
    '💵',
    '🤝',
    '📊',
    '🐶',
    '🐱',
    '🌱',
    '☀️',
    '🎓',
    '✏️',
    '📱',
    '🎉',
  ];

  // สีให้เลือก
  static const List<String> _colors = [
    'FF6B6B',
    'FF9800',
    'FFC107',
    '4CAF50',
    '00BCD4',
    '2196F3',
    '3F51B5',
    '9C27B0',
    'E91E63',
    '795548',
    '607D8B',
    'F44336',
    '8BC34A',
    '009688',
    'FF5722',
    '673AB7',
    '03A9F4',
    'CDDC39',
    'FF4081',
    '00E676',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการหมวดหมู่',
            style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'รายจ่าย'),
            Tab(text: 'รายรับ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList('expense'),
          _buildCategoryList('income'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(
          _tabController.index == 0 ? 'expense' : 'income',
        ),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('เพิ่มหมวด', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCategoryList(String type) {
    final categories = context
        .watch<CategoryProvider>()
        .categories
        .where((c) => c.type == type)
        .toList();

    if (categories.isEmpty) {
      return const Center(
        child: Text('ยังไม่มีหมวดหมู่', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        Color catColor = AppTheme.primaryColor;
        try {
          catColor = Color(int.parse('FF${cat.color}', radix: 16));
        } catch (_) {}

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: catColor.withValues(alpha: 0.15),
              child: Text(cat.icon, style: const TextStyle(fontSize: 20)),
            ),
            title: Text(cat.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              cat.isDefault ? 'หมวดหมู่เริ่มต้น' : 'หมวดหมู่ที่สร้าง',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            trailing: cat.isDefault
                ? Icon(Icons.lock_outline, color: Colors.grey[400], size: 18)
                : IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(cat),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _showAddDialog(String type) async {
    String selectedIcon = _icons.first;
    String selectedColor = _colors.first;
    final nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text('เพิ่มหมวด${type == 'expense' ? 'รายจ่าย' : 'รายรับ'}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview
                  Center(
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          Color(int.parse('FF$selectedColor', radix: 16))
                              .withValues(alpha: 0.2),
                      child: Text(selectedIcon,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ชื่อหมวด
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'ชื่อหมวดหมู่',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // เลือก Icon
                  const Text('เลือก Icon',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 160,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      itemCount: _icons.length,
                      itemBuilder: (_, i) {
                        final isSelected = _icons[i] == selectedIcon;
                        return GestureDetector(
                          onTap: () =>
                              setDialog(() => selectedIcon = _icons[i]),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                      .withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                              ),
                            ),
                            child: Center(
                              child: Text(_icons[i],
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // เลือกสี
                  const Text('เลือกสี',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colors.map((hex) {
                      final color = Color(int.parse('FF$hex', radix: 16));
                      final isSelected = hex == selectedColor;
                      return GestureDetector(
                        onTap: () => setDialog(() => selectedColor = hex),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.5),
                                      blurRadius: 6,
                                    )
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  return;
                }
                final newCat = Category(
                  name: name,
                  type: type,
                  icon: selectedIcon,
                  color: selectedColor,
                );
                await context.read<CategoryProvider>().addCategory(newCat);
                if (!context.mounted) {
                  return;
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
  }

  Future<void> _confirmDelete(Category cat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ลบหมวดหมู่'),
        content: Text('ต้องการลบ "${cat.name}" ใช่ไหม?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<CategoryProvider>().deleteCategory(cat.id!);
    }
  }
}
