import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// for simple functionality
final isSearchingProvider = StateProvider<bool>((ref) => false);
final selectedCategoryProvider = StateProvider<String>((ref) => "Default");
final initialRepeatProvider = StateProvider<String>((ref) => "No repeat");
final initalSelectedCategoryProvider =
    StateProvider<String>((ref) => "Default");
final isSelectMoreProvider = StateProvider<bool>((ref) => false);
final selectedTaskProvider =
    StateProvider<HashSet<int>>((ref) => HashSet<int>());

// for adding new tasks
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedTimeProvider = StateProvider<TimeOfDay?>((ref) => null);

// constants
const List<String> repeat = [
  "No repeat",
  "Daily",
  "Weekly",
  "Montly",
  "Yearly",
];

const List<String> menuOption = [
  "Task Lists",
  "Add in Batch Mode",
  "Remove Ads",
  "More Apps",
  "Send feedback",
  "Follow us",
  "Invite friends to the app",
  "Settings"
];
