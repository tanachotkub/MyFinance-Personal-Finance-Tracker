import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/category_provider.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction; // null = add mode, มีค่า = edit mode

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'expense';
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  bool get _isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final t = widget.transaction!;
      _type = t.type;
      _amountController.text = t.amount.toString();
      _noteController.text = t.note ?? '';
      _selectedDate = DateTime.parse(t.date);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isEditMode && _selectedCategory == null) {
      final categories = context.read<CategoryProvider>().categories;
      try {
        _selectedCategory = categories.firstWhere(
          (c) => c.id == widget.transaction!.categoryId,
        );
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final filteredCategories =
        categories.where((c) => c.type == _type).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'แก้ไขรายการ' : 'เพิ่มรายการ'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Toggle รายรับ/รายจ่าย
            _buildTypeToggle(),
            const SizedBox(height: 20),

            // จำนวนเงิน
            _buildAmountField(),
            const SizedBox(height: 16),

            // หมวดหมู่
            _buildCategoryPicker(filteredCategories),
            const SizedBox(height: 16),

            // วันที่
            _buildDatePicker(),
            const SizedBox(height: 16),

            // โน้ต
            _buildNoteField(),
            const SizedBox(height: 32),

            // ปุ่มบันทึก
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _TypeButton(
            label: 'รายจ่าย',
            icon: Icons.arrow_upward_rounded,
            color: AppTheme.expenseColor,
            selected: _type == 'expense',
            onTap: () => setState(() {
              _type = 'expense';
              _selectedCategory = null;
            }),
          ),
          _TypeButton(
            label: 'รายรับ',
            icon: Icons.arrow_downward_rounded,
            color: AppTheme.incomeColor,
            selected: _type == 'income',
            onTap: () => setState(() {
              _type = 'income';
              _selectedCategory = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: 'จำนวนเงิน',
        prefixText: '฿ ',
        prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) { return 'กรุณากรอกจำนวนเงิน'; }
        if (double.tryParse(v) == null) { return 'กรุณากรอกตัวเลขเท่านั้น'; }
        if (double.parse(v) <= 0) { return 'จำนวนเงินต้องมากกว่า 0'; }
        return null;
      },
    );
  }

  Widget _buildCategoryPicker(List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('หมวดหมู่', style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = _selectedCategory?.id == cat.id;
            Color catColor = AppTheme.primaryColor;
            try {
              catColor = Color(int.parse('FF${cat.color}', radix: 16));
            } catch (_) {}

            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? catColor.withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? catColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      cat.name,
                      style: TextStyle(
                        color: isSelected ? catColor : null,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedCategory == null)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('กรุณาเลือกหมวดหมู่',
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'โน้ต (ไม่บังคับ)',
        hintText: 'เพิ่มรายละเอียด...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }

  Widget _buildSaveButton() {
    final color = _type == 'income' ? AppTheme.incomeColor : AppTheme.expenseColor;
    return ElevatedButton(
      onPressed: _save,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        _isEditMode ? 'บันทึกการแก้ไข' : 'เพิ่มรายการ',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) { return; }
    if (_selectedCategory == null) { return; }

    final txProvider = context.read<TransactionProvider>();
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    if (_isEditMode) {
      final updated = widget.transaction!.copyWith(
        amount: double.parse(_amountController.text),
        type: _type,
        categoryId: _selectedCategory!.id,
        note: _noteController.text,
        date: dateStr,
      );
      await txProvider.updateTransaction(updated);
    } else {
      await txProvider.addTransaction(
        amount: double.parse(_amountController.text),
        type: _type,
        categoryId: _selectedCategory!.id!,
        note: _noteController.text,
        date: dateStr,
      );
    }

    if (!mounted) { return; }
    Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ลบรายการ'),
        content: const Text('ต้องการลบรายการนี้ใช่ไหม?'),
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
      await context.read<TransactionProvider>().deleteTransaction(
            widget.transaction!.id,
          );
      if (!mounted) { return; }
      Navigator.pop(context);
    }
  }
}

// Widget ปุ่ม Toggle รายรับ/รายจ่าย
class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.grey, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}