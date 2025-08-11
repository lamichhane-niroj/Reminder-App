import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/providers/category_provider.dart';
import 'package:todo_list/providers/homepage_provider.dart';
import 'package:todo_list/providers/task_provider.dart';
import 'package:todo_list/utils/app_theme.dart';
import 'package:todo_list/utils/formatters.dart';
import 'package:todo_list/utils/styles.dart';
import 'package:todo_list/models/category_model.dart';

class AddBatchModePage extends ConsumerStatefulWidget {
  const AddBatchModePage({super.key});

  @override
  ConsumerState<AddBatchModePage> createState() => _AddBatchModePageState();
}

class _AddBatchModePageState extends ConsumerState<AddBatchModePage> {
  final TextEditingController _taskTitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final initialCategory = ref.watch(selectedCategoryProvider);
    final initialRepeat = ref.watch(initialRepeatProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTime = ref.watch(selectedTimeProvider);
    final categories = ref.watch(categoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      floatingActionButton: SizedBox(
        height: 60,
        width: 60,
        child: FloatingActionButton(
          onPressed: () async {
            if (_taskTitleController.text.isNotEmpty) {
              final newTask = Task(
                title: _taskTitleController.text,
                dueDate: selectedDate,
                dueTime: selectedTime,
                category: initialCategory,
                repeat: initialRepeat,
                isCompleted: false,
              );
              await ref
                  .read(taskNotifierProvider.notifier)
                  .addBatchTask(newTask, initialCategory);
              ref.read(categoryProvider.notifier).loadCategories();
              ref.read(selectedDateProvider.notifier).state = null;
              ref.read(selectedTimeProvider.notifier).state = null;
              context.pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a task title')),
              );
            }
          },
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(Icons.check, size: 28, color: Colors.white),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 10,
        ),
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6D83F2),
                  Color(0xFF4A4E69),
                  Color(0xFF22223B),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.15),
                          child: Icon(Icons.playlist_add,
                              color: theme.colorScheme.primary, size: 32),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Batch Mode",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            final router = GoRouter.of(context);
                            if (router.canPop()) {
                              router.pop();
                            } else {
                              router.go('/');
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Task List Section
                    _batchSection(
                      context,
                      title: "Task List",
                      children: [
                        TextField(
                          controller: _taskTitleController,
                          autofocus: true,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          cursorColor: theme.colorScheme.primary,
                          style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                              fontFamily: 'Poppins'),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.list,
                                color: theme.colorScheme.primary),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.mic,
                                  color: theme.colorScheme.primary),
                              onPressed: () async {
                                bool isServiceAvailable =
                                    await SpeechToTextGoogleDialog.getInstance()
                                        .showGoogleDialog(
                                  onTextReceived: (data) {
                                    setState(() {
                                      _taskTitleController.text =
                                          data.toString();
                                    });
                                  },
                                );
                                if (!isServiceAvailable) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content:
                                        const Text('Service is not available'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(context).size.height -
                                              100,
                                      left: 16,
                                      right: 16,
                                    ),
                                  ));
                                }
                              },
                              // Add speech-to-text if needed
                            ),
                            hintMaxLines: 4,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: theme.colorScheme.primary),
                            ),
                            hintText: "Task 1\nTask 2\nTask 3\netc..",
                            hintStyle: TextStyle(
                              color: theme.hintColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Due Date Section
                    _batchSection(
                      context,
                      title: "Due Date & Time",
                      children: [
                        ListTile(
                          leading: Icon(Icons.calendar_month,
                              color: theme.colorScheme.primary),
                          title: Text(
                            selectedDate != null
                                ? AppFormatters.formatDate(selectedDate)
                                : "Pick a due date",
                            style: const TextStyle(
                                fontFamily: 'Poppins', color: Colors.white),
                          ),
                          trailing: selectedDate != null
                              ? IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.white70),
                                  onPressed: () {
                                    ref
                                        .read(selectedDateProvider.notifier)
                                        .state = null;
                                    ref
                                        .read(selectedTimeProvider.notifier)
                                        .state = null;
                                  },
                                )
                              : null,
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              ref.read(selectedDateProvider.notifier).state =
                                  pickedDate;
                            }
                          },
                        ),
                        if (selectedDate != null)
                          ListTile(
                            leading: Icon(Icons.watch_later_outlined,
                                color: theme.colorScheme.primary),
                            title: Text(
                              selectedTime != null
                                  ? AppFormatters.formatTime(
                                      selectedTime, context)
                                  : "Pick a time",
                              style: const TextStyle(
                                  fontFamily: 'Poppins', color: Colors.white),
                            ),
                            trailing: selectedTime != null
                                ? IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.white70),
                                    onPressed: () {
                                      ref
                                          .read(selectedTimeProvider.notifier)
                                          .state = null;
                                    },
                                  )
                                : null,
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: selectedTime ?? TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                ref.read(selectedTimeProvider.notifier).state =
                                    pickedTime;
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Repeat Section
                    if (selectedDate != null)
                      _batchSection(
                        context,
                        title: "Repeat",
                        children: [
                          ListTile(
                            leading: Icon(Icons.repeat,
                                color: theme.colorScheme.primary),
                            title: Text(
                              initialRepeat,
                              style: const TextStyle(
                                  fontFamily: 'Poppins', color: Colors.white),
                            ),
                            trailing: const Icon(Icons.arrow_drop_down,
                                color: Colors.white),
                            onTap: () async {
                              final value = await showModalBottomSheet<String>(
                                context: context,
                                backgroundColor: Colors.white.withOpacity(0.95),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24)),
                                ),
                                builder: (context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        child: Text(
                                          "Select Repeat",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      ...repeat.map((e) =>
                                          RadioListTile<String>(
                                            value: e,
                                            groupValue: initialRepeat,
                                            onChanged: (val) =>
                                                Navigator.of(context).pop(val),
                                            title: Text(e,
                                                style: const TextStyle(
                                                    fontFamily: 'Poppins')),
                                          )),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                },
                              );
                              if (value != null) {
                                ref.read(initialRepeatProvider.notifier).state =
                                    value;
                              }
                            },
                          ),
                        ],
                      ),
                    // Category Section
                    const SizedBox(height: 24),
                    _batchSection(
                      context,
                      title: "Add to List",
                      children: [
                        ListTile(
                          leading: Icon(Icons.list,
                              color: theme.colorScheme.primary),
                          title: Text(
                            initialCategory,
                            style: const TextStyle(
                                fontFamily: 'Poppins', color: Colors.white),
                          ),
                          trailing: const Icon(Icons.arrow_drop_down,
                              color: Colors.white),
                          onTap: () async {
                            final value = await showModalBottomSheet<String>(
                              context: context,
                              backgroundColor: Colors.white.withOpacity(0.95),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24)),
                              ),
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: Text(
                                        "Select List",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    ...categories.map((cat) =>
                                        RadioListTile<String>(
                                          value: cat.name,
                                          groupValue: initialCategory,
                                          onChanged: (val) =>
                                              Navigator.of(context).pop(val),
                                          title: Text(cat.name,
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins')),
                                        )),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              },
                            );
                            if (value != null) {
                              ref
                                  .read(selectedCategoryProvider.notifier)
                                  .state = value;
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section card with title and children
  Widget _batchSection(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ),
        Card(
          color: Colors.white.withOpacity(0.07),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
