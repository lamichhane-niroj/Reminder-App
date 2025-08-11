import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppFormatters {
  static String formatDate(DateTime? date) {
    if (date == null) {
      return "Select Date";
    }
    return "${date.day}/${date.month}/${date.year}";
  }

  static String formatTime(TimeOfDay? time, BuildContext context) {
    if (time == null) {
      return "Select Time";
    }
    return time.format(context);
  }

  static String formatDateTimeLabel({
    required DateTime date,
    TimeOfDay? time,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(date.year, date.month, date.day);

    final diff = dueDate.difference(today).inDays;

    String dayLabel;
    if (diff == -1) {
      dayLabel = 'Yesterday';
    } else if (diff == 0) {
      dayLabel = 'Today';
    } else if (diff == 1) {
      dayLabel = 'Tomorrow';
    } else {
      dayLabel = DateFormat('EEE, MMM d, yyyy').format(date);
    }

    if (time != null) {
      final dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      final timeString = DateFormat.jm().format(dateTime); // e.g., 3:00 PM
      return '$dayLabel, $timeString';
    } else {
      return dayLabel;
    }
  }
}
