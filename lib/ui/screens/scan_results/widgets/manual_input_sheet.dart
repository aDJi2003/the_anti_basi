import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../config/app_colors.dart';
import '../../../../data/models/inventory_item.dart';
import '../../../../data/models/scanned_item.dart';
import '../../../widgets/common/app_button.dart';

/// Bottom sheet for manual item input
class ManualInputSheet extends StatefulWidget {
  const ManualInputSheet({super.key});

  @override
  State<ManualInputSheet> createState() => _ManualInputSheetState();
}

class _ManualInputSheetState extends State<ManualInputSheet> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  ItemCategory _selectedCategory = ItemCategory.other;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Add Item Manually',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Item name
              _InputField(
                label: 'Item Name',
                child: TextField(
                  controller: _nameController,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'e.g., Milk, Eggs, Spinach',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.gray200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.gray200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category
              _InputField(
                label: 'Category',
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gray200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ItemCategory>(
                      value: _selectedCategory,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      borderRadius: BorderRadius.circular(12),
                      items: ItemCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(_categoryLabel(category)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Quantity and Expiry Date row
              Row(
                children: [
                  // Quantity
                  Expanded(
                    flex: 2,
                    child: _InputField(
                      label: 'Quantity',
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: '1',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.gray200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.gray200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.primary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Expiry Date
                  Expanded(
                    flex: 3,
                    child: _InputField(
                      label: 'Expiry Date',
                      child: GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.gray200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMM d, y').format(_expiryDate),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Add button
              AppButton(
                text: 'Add Item',
                icon: Icons.add_rounded,
                onPressed: _submit,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter item name')),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text) ?? 1;

    final item = ScannedItem(
      id: const Uuid().v4(),
      name: name,
      category: _selectedCategory,
      quantity: quantity,
      expiryDate: _expiryDate,
      isSelected: true,
    );

    Navigator.of(context).pop(item);
  }

  String _categoryLabel(ItemCategory category) {
    switch (category) {
      case ItemCategory.dairy:
        return 'Dairy';
      case ItemCategory.protein:
        return 'Protein';
      case ItemCategory.vegetable:
        return 'Vegetable';
      case ItemCategory.fruit:
        return 'Fruit';
      case ItemCategory.grain:
        return 'Grain';
      case ItemCategory.condiment:
        return 'Condiment';
      case ItemCategory.beverage:
        return 'Beverage';
      case ItemCategory.other:
        return 'Other';
    }
  }
}

/// Input field with label
class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
