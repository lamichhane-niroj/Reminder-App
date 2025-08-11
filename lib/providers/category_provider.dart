import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list/providers/homepage_provider.dart';
import 'package:todo_list/services/database_helper.dart';
import 'package:todo_list/models/category_model.dart';
import 'package:sqflite/sqflite.dart';

// providers for crud in categories
final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>(
  (ref) => CategoryNotifier(),
);

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('categories', orderBy: 'name');
    List<Category> categories = [];
    for (final row in result) {
      final id = row['id'] as int;
      final name = row['name'] as String;
      // Count total tasks in this category
      final totalTaskCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM tasks WHERE category = ?', [name],
      )) ?? 0;
      // Count due (not completed) tasks in this category
      final dueTaskCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM tasks WHERE category = ? AND isCompleted = 0', [name],
      )) ?? 0;
      categories.add(Category(
        id: id,
        name: name,
        totalTaskCount: totalTaskCount,
        dueTaskCount: dueTaskCount,
      ));
    }
    state = categories;
  }

  Future<void> addCategory(String category) async {
    await DatabaseHelper().addCategory(category);
    await loadCategories();
  }

  Future<void> removeCategory(String category, WidgetRef ref) async {
    await DatabaseHelper().deleteCategory(category);
    ref.read(selectedCategoryProvider.notifier).state = "Default";
    await loadCategories();
  }

  Future<void> editCategory(String oldCategory, String newCategory) async {
    await DatabaseHelper().updateCategory(oldCategory, newCategory);
    await loadCategories();
  }
}
