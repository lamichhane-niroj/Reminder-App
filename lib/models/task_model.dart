import 'package:flutter/material.dart';

class Task {
  int? id;
  String title;
  DateTime? dueDate;
  TimeOfDay? dueTime;
  String category;
  String repeat;
  bool isCompleted;

  Task({
    this.id,
    required this.title,
    this.dueDate,
    this.dueTime,
    this.category = "Default",
    this.repeat = "No repeat",
    this.isCompleted = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'dueTime': dueTime != null ? '${dueTime!.hour}:${dueTime!.minute}' : null,
      'category': category,
      'repeat': repeat,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      dueTime: map['dueTime'] != null
          ? TimeOfDay(
              hour: int.parse(map['dueTime'].split(':')[0]),
              minute: int.parse(map['dueTime'].split(':')[1]),
            )
          : null,
      category: map['category'],
      repeat: map['repeat'],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    String? category,
    String? repeat,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      category: category ?? this.category,
      repeat: repeat ?? this.repeat,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
