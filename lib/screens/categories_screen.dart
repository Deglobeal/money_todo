import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_todo/models/category.dart';
import 'package:money_todo/providers/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final List<IconData> _iconOptions = [
    Icons.label,
    Icons.shopping_bag,
    Icons.work,
    Icons.home,
    Icons.favorite,
    Icons.account_balance_wallet,
    Icons.flight,
    Icons.restaurant,
    Icons.school,
    Icons.fitness_center,
    Icons.pets,
    Icons.car_rental,
    Icons.local_hospital,
  ];

  final List<Color> _colorOptions = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  void _showCategoryDialog({TaskCategory? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    IconData selectedIcon = category?.iconData ?? Icons.label;
    Color selectedColor = category?.color ?? Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Category' : 'New Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _iconOptions.map((icon) {
                        final isSelected = icon == selectedIcon;
                        return InkWell(
                          onTap: () => setDialogState(() => selectedIcon = icon),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? selectedColor.withOpacity(0.2) : null,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? selectedColor : Colors.grey[300]!,
                              ),
                            ),
                            child: Icon(icon, color: isSelected ? selectedColor : Colors.grey),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _colorOptions.map((color) {
                        final isSelected = color == selectedColor;
                        return InkWell(
                          onTap: () => setDialogState(() => selectedColor = color),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    
                    final provider = context.read<TaskProvider>();
                    final newCategory = TaskCategory(
                      id: category?.id,
                      name: nameController.text.trim(),
                      colorValue: selectedColor.value,
                      iconName: _iconNameFromData(selectedIcon),
                    );
                    
                    if (isEditing) {
                      provider.updateCategory(newCategory);
                    } else {
                      provider.addCategory(newCategory);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _iconNameFromData(IconData icon) {
    final map = {
      Icons.shopping_bag: 'shopping',
      Icons.work: 'work',
      Icons.home: 'home',
      Icons.favorite: 'health',
      Icons.account_balance_wallet: 'finance',
      Icons.flight: 'travel',
      Icons.restaurant: 'food',
      Icons.school: 'education',
      Icons.fitness_center: 'fitness',
      Icons.pets: 'pets',
      Icons.car_rental: 'car',
      Icons.local_hospital: 'health',
    };
    return map[icon] ?? 'label';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: StreamBuilder<List<TaskCategory>>(
        stream: context.read<TaskProvider>()._firebase.categoriesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final categories = snapshot.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.read<TaskProvider>()._categories = categories;
          });

          if (categories.isEmpty) {
            return const Center(
              child: Text('No categories yet. Tap + to create one.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cat.color.withOpacity(0.2),
                    child: Icon(cat.iconData, color: cat.color),
                  ),
                  title: Text(cat.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showCategoryDialog(category: cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete Category?'),
                              content: const Text('Tasks in this category will become uncategorized.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<TaskProvider>().deleteCategory(cat.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}