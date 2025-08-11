import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list/services/database_helper.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Map<String, String>>(
  (ref) => SettingsNotifier(),
);

class SettingsNotifier extends StateNotifier<Map<String, String>> {
  SettingsNotifier() : super({}) {
    _loadSettings();
  }

  final _db = DatabaseHelper();

  Future<void> _loadSettings() async {
    final settings = await _db.getAllSettings();
    state = settings;
  }

  Future<void> updateSetting(String key, String value) async {
    await _db.updateSetting(key, value);
    state = {...state, key: value};
  }

  String? get(String key) => state[key];

  bool getBool(String key) => state[key] == 'true';

  int? getInt(String key) => int.tryParse(state[key] ?? '');

  TimeOfDay? getTime(String key) {
    final value = state[key];
    if (value == null || !value.contains(":")) return null;
    final parts = value.split(":");
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> resetToDefault() async {
    await _db.resetSettingsToDefault();
    await _loadSettings();
  }
}
