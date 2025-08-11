import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/models/category_model.dart';
import 'package:todo_list/providers/category_provider.dart';
import 'package:todo_list/providers/homepage_provider.dart';
import 'package:todo_list/providers/task_provider.dart';
import 'package:todo_list/utils/app_theme.dart';
import 'package:todo_list/utils/formatters.dart';
import 'package:todo_list/utils/styles.dart';

class EditTask extends ConsumerStatefulWidget {
  const EditTask({super.key, required this.task});
  final Task task;

  @override
  ConsumerState<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends ConsumerState<EditTask> {
  late final TextEditingController _taskTitleController;
  bool _hasChangesMade = false;

  @override
  void initState() {
    super.initState();
    _taskTitleController = TextEditingController(text: widget.task.title);
  }

  @override
  void dispose() {
    _taskTitleController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return _hasChangesMade
        ? await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                title: Text('Are you sure?', style: AppStyles.dialogBoxTitle),
                content: Text('Quit without saving?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('CANCEL', style: AppStyles.dialogBoxConfirm),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('EXIT', style: AppStyles.dialogBoxConfirm),
                  ),
                ],
              ),
            ) ??
            false
        : true;
  }

  @override
  Widget build(BuildContext context) {
    final initialCategoryProvider = ref.watch(initalSelectedCategoryProvider);
    final currentCategory = ref.watch(selectedCategoryProvider);
    final initialRepeat = ref.watch(initialRepeatProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTime = ref.watch(selectedTimeProvider);
    final categories = ref.watch(categoryProvider);
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        floatingActionButton: SizedBox(
          height: 60,
          width: 60,
          child: FloatingActionButton(
            onPressed: () async {
              if (_taskTitleController.text.isNotEmpty) {
                final updatedTask = widget.task.copyWith(
                  title: _taskTitleController.text,
                  dueDate: selectedDate,
                  dueTime: selectedTime,
                  category: initialCategoryProvider,
                  repeat: initialRepeat,
                );
                await ref
                    .read(taskNotifierProvider.notifier)
                    .updateTask(updatedTask, currentCategory);
                ref.read(categoryProvider.notifier).loadCategories();
                ref.read(selectedDateProvider.notifier).state = null;
                ref.read(selectedTimeProvider.notifier).state = null;
                context.pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a task title')),
                );
              }
            },
            backgroundColor: theme.colorScheme.primary,
            child: Icon(Icons.check, size: 28, color: Colors.white),
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
                            child: Icon(Icons.edit,
                                color: theme.colorScheme.primary, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "Edit Task",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          // Modernized menu bar (ensure this is visible)
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.white),
                            onPressed: () async {
                              await ref
                                  .read(taskNotifierProvider.notifier)
                                  .deleteTask(widget.task.id!, currentCategory);
                              ref
                                  .read(categoryProvider.notifier)
                                  .loadCategories();
                              context.pop();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Task Details Section
                      _taskSection(
                        context,
                        title: "Task Details",
                        children: [
                          TextField(
                            controller: _taskTitleController,
                            onChanged: (e) {
                              if (_hasChangesMade == false) {
                                _hasChangesMade = true;
                              }
                            },
                            autofocus: true,
                            cursorColor: theme.colorScheme.primary,
                            style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontFamily: 'Poppins'),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.title,
                                  color: theme.colorScheme.primary),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.mic,
                                    color: theme.colorScheme.primary),
                                onPressed: () async {
                                  bool isServiceAvailable =
                                      await SpeechToTextGoogleDialog
                                              .getInstance()
                                          .showGoogleDialog(
                                    onTextReceived: (data) {
                                      setState(() {
                                        _taskTitleController.text =
                                            data.toString();
                                        _hasChangesMade = true;
                                      });
                                    },
                                  );
                                  if (!isServiceAvailable) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('Service is not available'),
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
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: theme.dividerColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: theme.colorScheme.primary),
                              ),
                              hintText: "Enter Task Title",
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
                      _taskSection(
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
                              style: TextStyle(
                                  fontFamily: 'Poppins', color: Colors.white),
                            ),
                            trailing: selectedDate != null
                                ? IconButton(
                                    icon: Icon(Icons.cancel,
                                        color: Colors.white70),
                                    onPressed: () {
                                      ref
                                          .read(selectedDateProvider.notifier)
                                          .state = null;
                                      ref
                                          .read(selectedTimeProvider.notifier)
                                          .state = null;
                                      setState(() => _hasChangesMade = true);
                                    },
                                  )
                                : null,
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(1901),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                ref.read(selectedDateProvider.notifier).state =
                                    pickedDate;
                                setState(() => _hasChangesMade = true);
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
                                style: TextStyle(
                                    fontFamily: 'Poppins', color: Colors.white),
                              ),
                              trailing: selectedTime != null
                                  ? IconButton(
                                      icon: Icon(Icons.cancel,
                                          color: Colors.white70),
                                      onPressed: () {
                                        ref
                                            .read(selectedTimeProvider.notifier)
                                            .state = null;
                                        setState(() => _hasChangesMade = true);
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
                                  ref
                                      .read(selectedTimeProvider.notifier)
                                      .state = pickedTime;
                                  setState(() => _hasChangesMade = true);
                                }
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Repeat Section
                      if (selectedDate != null)
                        _taskSection(
                          context,
                          title: "Repeat",
                          children: [
                            ListTile(
                              leading: Icon(Icons.repeat,
                                  color: theme.colorScheme.primary),
                              title: Text(
                                initialRepeat,
                                style: TextStyle(
                                    fontFamily: 'Poppins', color: Colors.white),
                              ),
                              trailing: Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                              onTap: () async {
                                final value =
                                    await showModalBottomSheet<String>(
                                  context: context,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.95),
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
                                        ...repeat
                                            .map((e) => RadioListTile<String>(
                                                  value: e,
                                                  groupValue: initialRepeat,
                                                  onChanged: (val) =>
                                                      Navigator.of(context)
                                                          .pop(val),
                                                  title: Text(e,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Poppins')),
                                                )),
                                        const SizedBox(height: 16),
                                      ],
                                    );
                                  },
                                );
                                if (value != null) {
                                  ref
                                      .read(initialRepeatProvider.notifier)
                                      .state = value;
                                  setState(() => _hasChangesMade = true);
                                }
                              },
                            ),
                          ],
                        ),
                      // Category Section
                      const SizedBox(height: 24),
                      _taskSection(
                        context,
                        title: "Add to List",
                        children: [
                          ListTile(
                            leading: Icon(Icons.list,
                                color: theme.colorScheme.primary),
                            title: Text(
                              initialCategoryProvider,
                              style: TextStyle(
                                  fontFamily: 'Poppins', color: Colors.white),
                            ),
                            trailing: Icon(Icons.arrow_drop_down,
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
                                            groupValue: initialCategoryProvider,
                                            onChanged: (val) =>
                                                Navigator.of(context).pop(val),
                                            title: Text(cat.name,
                                                style: TextStyle(
                                                    fontFamily: 'Poppins')),
                                          )),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                },
                              );
                              if (value != null) {
                                ref
                                    .read(
                                        initalSelectedCategoryProvider.notifier)
                                    .state = value;
                                setState(() => _hasChangesMade = true);
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
      ),
    );
  }

  // Section card with title and children
  Widget _taskSection(BuildContext context,
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

  // Helper for menu options
  Widget _menuOptionTile(BuildContext context, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: const TextStyle(fontFamily: 'Poppins')),
      onTap: () {
        Navigator.of(context).pop();
        switch (label) {
          case "Task Lists":
            GoRouter.of(context).push("/task");
            break;
          case "Add in Batch Mode":
            GoRouter.of(context).push("/batch");
            break;
          case "Settings":
            GoRouter.of(context).push("/settings");
            break;
          // Add more cases as needed for other menu options
        }
      },
    );
  }
}
