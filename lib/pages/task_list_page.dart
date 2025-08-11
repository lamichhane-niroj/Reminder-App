import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_list/providers/category_provider.dart';
import 'package:todo_list/providers/homepage_provider.dart';
import 'package:todo_list/providers/task_provider.dart';
import 'package:todo_list/utils/app_theme.dart';
import 'package:todo_list/utils/styles.dart';
import 'package:todo_list/models/category_model.dart';

class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);
    final theme = Theme.of(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController newCategoryTitle = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Text('New List',
                  style:
                      AppStyles.dialogBoxTitle.copyWith(fontFamily: 'Poppins')),
              content: TextField(
                controller: newCategoryTitle,
                decoration: const InputDecoration(hintText: "Enter List Name"),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel',
                      style: AppStyles.dialogBoxConfirm
                          .copyWith(fontFamily: 'Poppins')),
                ),
                TextButton(
                  onPressed: () {
                    ref
                        .read(categoryProvider.notifier)
                        .addCategory(newCategoryTitle.text.trim());
                    Navigator.of(context).pop();
                  },
                  child: Text('Add',
                      style: AppStyles.dialogBoxConfirm
                          .copyWith(fontFamily: 'Poppins')),
                ),
              ],
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
        tooltip: 'Add New List',
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
                          child: Icon(Icons.menu_open_rounded,
                              color: theme.colorScheme.primary, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Task Lists",
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
                    // Category List Section
                    _categorySection(context, ref, categories),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section card for categories
  Widget _categorySection(
      BuildContext context, WidgetRef ref, List<Category> categories) {
    final theme = Theme.of(context);
    return Card(
      color: Colors.white.withOpacity(0.07),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          children: [
            ...categories.map((cat) => Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: ListTile(
                    tileColor: theme.colorScheme.secondary.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side:
                            BorderSide(color: theme.dividerColor, width: 0.5)),
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).state =
                          cat.name;
                      ref
                          .read(taskNotifierProvider.notifier)
                          .filterTasks(cat.name);
                      context.pop();
                    },
                    onLongPress: () async {
                      await showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.white.withOpacity(0.95),
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'List Options',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('Edit',
                                    style: TextStyle(fontFamily: 'Poppins')),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  TextEditingController categoryTitle =
                                      TextEditingController(text: cat.name);
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      title: Text('Edit List',
                                          style: AppStyles.dialogBoxTitle
                                              .copyWith(fontFamily: 'Poppins')),
                                      content: TextField(
                                        controller: categoryTitle,
                                        decoration: const InputDecoration(
                                            hintText: "Enter List Name"),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text('CANCEL',
                                              style: AppStyles.dialogBoxConfirm
                                                  .copyWith(
                                                      fontFamily: 'Poppins')),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ref
                                                .read(categoryProvider.notifier)
                                                .editCategory(cat.name,
                                                    categoryTitle.text.trim());
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('SAVE',
                                              style: AppStyles.dialogBoxConfirm
                                                  .copyWith(
                                                      fontFamily: 'Poppins')),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete',
                                    style: TextStyle(fontFamily: 'Poppins')),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      title: Text('Are you sure?',
                                          style: AppStyles.dialogBoxTitle
                                              .copyWith(fontFamily: 'Poppins')),
                                      content: const Text(
                                          'All tasks from the list will also be deleted.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text('CANCEL',
                                              style: AppStyles.dialogBoxConfirm
                                                  .copyWith(
                                                      fontFamily: 'Poppins')),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ref
                                                .read(categoryProvider.notifier)
                                                .removeCategory(cat.name, ref);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('DELETE',
                                              style: AppStyles.dialogBoxCancel
                                                  .copyWith(
                                                      fontFamily: 'Poppins')),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.close),
                                title: const Text('Cancel',
                                    style: TextStyle(fontFamily: 'Poppins')),
                                onTap: () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(cat.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500)),
                    subtitle: Text(
                        "Tasks: " +
                            cat.totalTaskCount.toString() +
                            " | Due: " +
                            cat.dueTaskCount.toString(),
                        style: const TextStyle(
                            color: Colors.white70, fontFamily: 'Poppins')),
                    trailing: cat.name != "Default"
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    TextEditingController categoryTitle =
                                        TextEditingController(text: cat.name);
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        title: Text('Edit List',
                                            style: AppStyles.dialogBoxTitle
                                                .copyWith(
                                                    fontFamily: 'Poppins')),
                                        content: TextField(
                                          controller: categoryTitle,
                                          decoration: const InputDecoration(
                                              hintText: "Enter List Name"),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text('CANCEL',
                                                style: AppStyles
                                                    .dialogBoxConfirm
                                                    .copyWith(
                                                        fontFamily: 'Poppins')),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      categoryProvider.notifier)
                                                  .editCategory(
                                                      cat.name,
                                                      categoryTitle.text
                                                          .trim());
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('SAVE',
                                                style: AppStyles
                                                    .dialogBoxConfirm
                                                    .copyWith(
                                                        fontFamily: 'Poppins')),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white)),
                              IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        title: Text('Are you sure?',
                                            style: AppStyles.dialogBoxTitle
                                                .copyWith(
                                                    fontFamily: 'Poppins')),
                                        content: const Text(
                                            'All tasks from the list will also be deleted.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text('CANCEL',
                                                style: AppStyles
                                                    .dialogBoxConfirm
                                                    .copyWith(
                                                        fontFamily: 'Poppins')),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      categoryProvider.notifier)
                                                  .removeCategory(
                                                      cat.name, ref);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('DELETE',
                                                style: AppStyles.dialogBoxCancel
                                                    .copyWith(
                                                        fontFamily: 'Poppins')),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white)),
                            ],
                          )
                        : null,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
