import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/providers/homepage_provider.dart';
import 'package:todo_list/services/database_helper.dart';
import 'package:todo_list/services/notification_helper.dart';

// creation of providers
final searchTermProvider = StateProvider<String?>((ref) => null);

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);

  Future<void> loadTasks() async {
    state = await DatabaseHelper().getTasks();
  }

  Future<void> filterTasks(String category) async {
    state = await DatabaseHelper().getTasksByCategory(category);
  }

  Future<void> searchTasks(String query) async {
    state = await DatabaseHelper().getTasksBySearchTerm(query);
  }

  DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> addTask(Task task, String category) async {
    final int newTaskId = await DatabaseHelper().insertTask(task);

    if (task.dueDate != null) {
      await NotificationService().scheduleNotification(
        id: newTaskId,
        title: task.title,
        repeat: task.repeat,
        body: 'Due at ${task.dueTime}',
        scheduledDateTime: combineDateAndTime(task.dueDate!,
            task.dueTime ?? const TimeOfDay(hour: 20, minute: 0)),
      );
    }

    await filterTasks(category);
  }

  Future<void> addBatchTask(Task task, String category) async {
    final int newTaskId = await DatabaseHelper().insertTaskInBatch(task);

    if (task.dueDate != null) {
      await NotificationService().scheduleNotification(
        id: newTaskId,
        title: task.title,
        repeat: task.repeat,
        body: 'Due at ${task.dueTime}',
        scheduledDateTime: combineDateAndTime(task.dueDate!,
            task.dueTime ?? const TimeOfDay(hour: 20, minute: 0)),
      );
    }
    await filterTasks(category);
  }

  Future<void> updateTask(Task task, String category) async {
    final int newTaskId = await DatabaseHelper().updateTask(task);

    if (task.dueDate != null) {
      await NotificationService().scheduleNotification(
        id: newTaskId,
        title: task.title,
        repeat: task.repeat,
        body: '${task.dueTime!.hour} : ${task.dueTime!.minute}',
        scheduledDateTime: combineDateAndTime(task.dueDate!,
            task.dueTime ?? const TimeOfDay(hour: 20, minute: 0)),
      );
    }
    await filterTasks(category);
  }

  Future<void> addToFinish(Task task, String category) async {
    await DatabaseHelper().updateTask(task);
    await filterTasks(category);
  }

  Future<void> deleteTask(int id, String category) async {
    await DatabaseHelper().deleteTask(id);
    await filterTasks(category);
  }

  Future<void> deleteMultipleTask(
      HashSet<int> selectedTask, String category) async {
    await DatabaseHelper().deleteTasksByIds(selectedTask);
    await filterTasks(category);
  }

  Future<void> finishedMultipleTask(
      HashSet<int> selectedTask, String category, int isFinished) async {
    await DatabaseHelper().updateTasksByIds(
      selectedTask,
      {'isCompleted': isFinished},
    );
    await filterTasks(category);
  }
}

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier()
    ..filterTasks(ref.read(selectedCategoryProvider.notifier).state);
});
