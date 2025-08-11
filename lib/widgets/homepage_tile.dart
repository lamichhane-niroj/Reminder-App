// Modern, card-like HomeTaskTile with improved structure and comments
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/providers/homepage_provider.dart';
import 'package:todo_list/providers/settings_provider.dart';
import 'package:todo_list/providers/task_provider.dart';
import 'package:todo_list/utils/app_theme.dart';
import 'package:todo_list/utils/formatters.dart';
import 'package:todo_list/utils/styles.dart';

class HomeTaskTile extends ConsumerWidget {
  const HomeTaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onLongPress,
    required this.editTask,
    this.compact = true,
  });

  final Task task;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final void Function()? editTask;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelectMore = ref.watch(isSelectMoreProvider);
    final isSelected = ref.read(selectedTaskProvider.notifier).state.contains(task.id);
    final theme = Theme.of(context);
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(compact ? 12 : 18),
      color: theme.cardColor.withOpacity(0.97),
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 12 : 18),
        onTap: isSelectMore ? onTap : editTask,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 12 : 18),
            border: Border.all(
              color: isSelected ? AppColors.accentTeal : theme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: compact ? 10 : 16, horizontal: compact ? 12 : 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (bool? value) async {
                  final notifier = ref.read(settingsProvider.notifier);
                  if (!task.isCompleted) {
                    if (notifier.getBool('confirmFinishingTasks')) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          title: const Text('Are you sure?'),
                          content: const Text('Set tasks as finished?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () {
                                handleConfirm(ref, context);
                                Navigator.of(context).pop();
                              },
                              child: const Text('YES'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      handleConfirm(ref, context);
                    }
                  }
                },
                activeColor: AppColors.accentTeal,
                checkColor: Colors.white,
                side: BorderSide(color: AppColors.accentTeal, width: 2),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppStyles.heading1.copyWith(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: compact ? 16 : 19,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.dueDate != null
                          ? AppFormatters.formatDateTimeLabel(
                              date: task.dueDate!,
                              time: task.dueTime,
                            )
                          : 'No due date',
                      style: AppStyles.subtitle2.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        fontSize: compact ? 13 : 15,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSelectMore)
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.accentTeal, size: compact ? 20 : 22),
                  onPressed: editTask,
                  tooltip: 'Edit Task',
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Handles marking a task as finished
  void handleConfirm(WidgetRef ref, BuildContext context) async {
    ref.read(taskNotifierProvider.notifier).addToFinish(
        task.copyWith(isCompleted: true),
        ref.read(selectedCategoryProvider.notifier).state);
    ref.read(selectedTaskProvider.notifier).state.remove(task.id);
    if (ref.read(selectedTaskProvider.notifier).state.isEmpty) {
      ref.read(isSelectMoreProvider.notifier).state = false;
    }
  }
}
