import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_list/models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // initialization
  Future<Database> _initDatabase() async {
    String path = await getDatabasesPath();
    String databasePath = join(path, 'todo_app.db');
    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // create table for databases
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        dueDate INTEGER,
        dueTime TEXT,
        category TEXT,
        repeat TEXT,
        isCompleted INTEGER
      )
    ''');

    await db.execute('''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE
    )
    ''');

    final defaultCategories = [
      "Default",
      "Personal",
      "Wishlist",
      "Shopping",
      "Work"
    ];
    for (final name in defaultCategories) {
      await db.insert('categories', {'name': name});
    }

    await db.execute('''
    CREATE TABLE settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
    ''');

    final defaultSettings = {
      'isStatusBarOn': 'false',
      'confirmFinishingTasks': 'true',
      'confirmRepeatingTasks': 'true',
      'foundInClipboard': 'false',
      'isVoiceOn': 'true',
      'isVibrationOn': 'true',
      'daySummary': 'true',
      'quickTaskbar': 'true',
      'startupCategory': 'Default',
      'firstDayOfWeek': 'Sunday',
      'timeFormat': '12-hour',
      'sortOrder': 'Alphabetically',
      'sound': 'Default',
      'taskNotification': 'OnTime',
      'defaultDueDate': 'NoDate'
    };

    for (var entry in defaultSettings.entries) {
      await db.insert('settings', {
        'key': entry.key,
        'value': entry.value,
      });
    }
  }

  // CRUD FOR CATEGORIES
  // get all the categories
  Future<List<String>> getCategories() async {
    final db = await _instance.database;
    final result = await db.query('categories', orderBy: 'name');
    return result.map((row) => row['name'] as String).toList();
  }

  // insert to category
  Future<void> addCategory(String name) async {
    final db = await _instance.database;
    await db.insert('categories', {'name': name},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // remove from category
  Future<void> deleteCategory(String name) async {
    final db = await _instance.database;
    await db.delete('categories', where: 'name = ?', whereArgs: [name]);
    await db.delete('tasks', where: 'category = ?', whereArgs: [name]);
  }

  // update existing category
  Future<void> updateCategory(String oldName, String newName) async {
    final db = await _instance.database;
    await db.update(
      'categories',
      {'name': newName},
      where: 'name = ?',
      whereArgs: [oldName],
    );

    // dont forget to update all the task when category is updated
    await db.update(
      'tasks',
      {'category': newName},
      where: 'category = ?',
      whereArgs: [oldName],
    );
  }

  // CRUD FOR TASKS
  // add new task
  Future<int> insertTask(Task task) async {
    Database db = await _instance.database;
    return await db.insert('tasks', task.toMap());
  }

  // add task in batch
  Future<int> insertTaskInBatch(Task task) async {
    List<String> lines = task.title
        .replaceAll(r'\n', '\n')
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final results = await Future.wait(
      lines.map((title) => insertTask(task.copyWith(title: title))),
    );
    return results.where((id) => id > 0).length;
  }

  // fetch all task
  Future<List<Task>> getTasks() async {
    Database db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // update task
  Future<int> updateTask(Task task) async {
    Database db = await _instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // delete task
  Future<int> deleteTask(int id) async {
    Database db = await _instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // delete multiple task at once
  Future<int> deleteTasksByIds(Set<int> ids) async {
    if (ids.isEmpty) return 0;
    final db = await _instance.database;
    final placeholders = List.filled(ids.length, '?').join(', ');
    return await db.delete(
      'tasks',
      where: 'id IN ($placeholders)',
      whereArgs: ids.toList(),
    );
  }

  // delete all task of the category
  Future<int> deleteTasksByCategory(String category) async {
    final db = await _instance.database;
    return await db.delete(
      'tasks',
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  // update task by ids
  Future<int> updateTasksByIds(
      Set<int> ids, Map<String, dynamic> values) async {
    if (ids.isEmpty) return 0;
    final db = await _instance.database;
    final placeholders = List.filled(ids.length, '?').join(', ');
    return await db.update(
      'tasks',
      values,
      where: 'id IN ($placeholders)',
      whereArgs: ids.toList(),
    );
  }

  // search task by title
  Future<List<Task>> getTasksBySearchTerm(String searchTerm) async {
    Database db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'title LIKE ?',
      whereArgs: ['%$searchTerm%'],
    );
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<List<Task>> getTasksByCategory(String category) async {
    Database db = await _instance.database;

    if (category == "All Lists") {
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'isCompleted = ?',
        whereArgs: [0],
      );

      return List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });
    } else if (category == "Finished") {
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'isCompleted = ?',
        whereArgs: [1],
      );

      return List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });
    } else {
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'category = ? AND isCompleted = ?',
        whereArgs: [category, 0],
      );

      return List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });
    }
  }

  // CRUD for settings
  // Get a setting by key
  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String;
    }
    return null;
  }

  // Get all settings
  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final result = await db.query('settings');
    return {
      for (var row in result) row['key'] as String: row['value'] as String,
    };
  }

  // Update a setting
  Future<void> updateSetting(String key, String value) async {
    final db = await database;
    await db.update(
      'settings',
      {'value': value},
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  // Check if a setting exists
  Future<bool> settingExists(String key) async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      columns: ['key'],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Reset all settings to default
  Future<void> resetSettingsToDefault() async {
    final db = await database;

    const defaultSettings = {
      'isStatusBarOn': 'true',
      'confirmFinishingTasks': 'true',
      'confirmRepeatingTasks': 'true',
      'foundInClipboard': 'true',
      'isVoiceOn': 'true',
      'isVibrationOn': 'true',
      'daySummary': 'true',
      'quickTaskbar': 'true',
      'startupCategory': 'Default',
      'firstDayOfWeek': 'Sunday',
      'timeFormat': '12-hour',
      'darkMode': 'true',
      'sound': 'Default',
      'defaultDueDate': 'NoDate'
    };

    // You can clear all and reinsert, or update one by one:
    for (var entry in defaultSettings.entries) {
      await db.update(
        'settings',
        {'value': entry.value},
        where: 'key = ?',
        whereArgs: [entry.key],
      );
    }
  }
}
