import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/providers/category_provider.dart';
import 'package:todo_list/providers/homepage_provider.dart';
import 'package:todo_list/providers/settings_provider.dart';
import 'package:todo_list/providers/task_provider.dart';
import 'package:todo_list/utils/app_theme.dart';
import 'package:todo_list/utils/styles.dart';
import 'package:todo_list/widgets/homepage_tile.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _quickTask = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _clipboardText;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), _checkClipboard);
  }

  // Clipboard check for quick task
  Future<void> _checkClipboard() async {
    final notifier = ref.read(settingsProvider.notifier);
    while (notifier.state.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    final startupList =
        ref.read(settingsProvider.notifier).get('startupCategory') ?? "Default";
    ref.read(selectedCategoryProvider.notifier).state = startupList;
    await ref.read(taskNotifierProvider.notifier).filterTasks(startupList);
    final clipboardData = await Clipboard.getData('text/plain');
    final text = clipboardData?.text?.trim();
    if (text != null &&
        text.isNotEmpty &&
        text != _clipboardText &&
        notifier.getBool('foundInClipboard')) {
      _clipboardText = text;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
          action: SnackBarAction(
            label: 'Add',
            onPressed: () async {
              context.push('/add_task', extra: text);
            },
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = ref.watch(isSearchingProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final taskList = ref.watch(taskNotifierProvider);
    final groupedTasks = groupTasksByDueDate(taskList);
    final nonEmptyGroups =
        groupedTasks.entries.where((entry) => entry.value.isNotEmpty).toList();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      drawer: Drawer(
        child: Stack(
          children: [
            // Gradient background for the drawer
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
            Column(
              children: [
                // Large user/avatar header
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.15),
                        child: const Icon(Icons.account_circle,
                            color: Colors.white, size: 48),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome!",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Your productivity hub",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu options with cards and dividers
                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    children: [
                      _drawerMenuCard(context, "Task Lists", Icons.list_alt),
                      _drawerMenuCard(
                          context, "Add in Batch Mode", Icons.playlist_add),
                      _drawerMenuCard(context, "Settings", Icons.settings),
                      const Divider(
                          color: Colors.white24,
                          height: 24,
                          thickness: 1,
                          indent: 12,
                          endIndent: 12),
                      _drawerMenuCard(
                          context, "Remove Ads", Icons.remove_circle_outline),
                      _drawerMenuCard(context, "More Apps", Icons.apps),
                      _drawerMenuCard(context, "Send feedback", Icons.feedback),
                      _drawerMenuCard(context, "Follow us", Icons.people),
                      _drawerMenuCard(context, "Invite friends to the app",
                          Icons.group_add),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isSearching)
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            tooltip: 'Menu',
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: isSearching
                            ? TextField(
                                controller: _searchController,
                                autofocus: true,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  hintText: 'Search tasks...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontFamily: 'Poppins',
                                    fontSize: 20,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onChanged: (query) {
                                  if (query.isNotEmpty) {
                                    ref
                                        .read(taskNotifierProvider.notifier)
                                        .searchTasks(query);
                                  } else {
                                    ref
                                        .read(taskNotifierProvider.notifier)
                                        .filterTasks(selectedCategory);
                                  }
                                },
                              )
                            : const Text(
                                "My Tasks",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 1.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                      ),
                      const SizedBox(width: 8),
                      isSearching
                          ? IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              tooltip: 'Cancel search',
                              onPressed: () {
                                _searchController.clear();
                                ref.read(isSearchingProvider.notifier).state =
                                    false;
                                ref
                                    .read(taskNotifierProvider.notifier)
                                    .filterTasks(selectedCategory);
                              },
                            )
                          : IconButton(
                              icon:
                                  const Icon(Icons.search, color: Colors.white),
                              tooltip: 'Search',
                              onPressed: () {
                                ref.read(isSearchingProvider.notifier).state =
                                    true;
                              },
                            ),
                      // User avatar/greeting (settings button)
                      if (!isSearching)
                        GestureDetector(
                          onTap: () => context.push('/settings'),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.18),
                            child: const Icon(Icons.settings,
                                color: Colors.white, size: 28),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isSearching) ...[
                  // 3. Category selector: pill-shaped chips with accent color and shadow
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: [
                          "All Lists",
                          ...ref.watch(categoryProvider).map((cat) => cat.name),
                          "Finished"
                        ].length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final categories = [
                            "All Lists",
                            ...ref
                                .watch(categoryProvider)
                                .map((cat) => cat.name),
                            "Finished"
                          ];
                          final cat = categories[index];
                          final isSelected = cat == selectedCategory;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.18),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () {
                                ref
                                    .read(selectedCategoryProvider.notifier)
                                    .state = cat;
                                ref
                                    .read(taskNotifierProvider.notifier)
                                    .filterTasks(cat);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.8),
                                    fontFamily: 'Poppins',
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                // 4. Task list: clean, slightly elevated cards
                Expanded(
                  child: taskList.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 8),
                          itemCount: nonEmptyGroups.fold<int>(0,
                              (prev, group) => prev + 1 + group.value.length),
                          itemBuilder: (context, index) {
                            int currentIndex = 0;
                            for (var group in nonEmptyGroups) {
                              if (index == currentIndex) {
                                // 1. Overdue group header with icon and accent
                                return !isSearching
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, left: 32, bottom: 5),
                                        child: Row(
                                          children: [
                                            if (group.key == "Overdue") ...[
                                              const Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: AppColors.red,
                                                  size: 26),
                                              const SizedBox(width: 8),
                                              Text(
                                                group.key,
                                                style:
                                                    AppStyles.heading2.copyWith(
                                                  fontSize: 22,
                                                  color: AppColors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ] else ...[
                                              Text(
                                                group.key,
                                                style: AppStyles.heading1
                                                    .copyWith(fontSize: 20),
                                              ),
                                            ],
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              }
                              currentIndex++;
                              if (index < currentIndex + group.value.length) {
                                final task = group.value[index - currentIndex];
                                return AnimatedOpacity(
                                  opacity: 1.0,
                                  duration: const Duration(milliseconds: 350),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Material(
                                      elevation: 3,
                                      borderRadius: BorderRadius.circular(18),
                                      color: Colors.white.withOpacity(0.13),
                                      child: HomeTaskTile(
                                        task: task,
                                        editTask: () {
                                          ref
                                              .read(
                                                  selectedDateProvider.notifier)
                                              .state = task.dueDate;
                                          ref
                                              .read(
                                                  selectedTimeProvider.notifier)
                                              .state = task.dueTime;
                                          ref
                                              .read(
                                                  initalSelectedCategoryProvider
                                                      .notifier)
                                              .state = task.category;
                                          ref
                                              .read(initialRepeatProvider
                                                  .notifier)
                                              .state = task.repeat;
                                          context.push("/edit", extra: task);
                                        },
                                        onLongPress: () async {
                                          await showModalBottomSheet(
                                            context: context,
                                            backgroundColor:
                                                Colors.white.withOpacity(0.97),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(24)),
                                            ),
                                            builder: (context) {
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16),
                                                    child: Text(
                                                      'Task Options',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading:
                                                        const Icon(Icons.edit),
                                                    title: const Text('Edit',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins')),
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      ref
                                                          .read(
                                                              selectedDateProvider
                                                                  .notifier)
                                                          .state = task.dueDate;
                                                      ref
                                                          .read(
                                                              selectedTimeProvider
                                                                  .notifier)
                                                          .state = task.dueTime;
                                                      ref
                                                          .read(
                                                              initalSelectedCategoryProvider
                                                                  .notifier)
                                                          .state = task.category;
                                                      ref
                                                          .read(
                                                              initialRepeatProvider
                                                                  .notifier)
                                                          .state = task.repeat;
                                                      context.push("/edit",
                                                          extra: task);
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: Icon(task
                                                            .isCompleted
                                                        ? Icons.undo
                                                        : Icons.check_circle),
                                                    title: Text(
                                                        task.isCompleted
                                                            ? 'Mark as Undone'
                                                            : 'Mark as Done',
                                                        style: const TextStyle(
                                                            fontFamily:
                                                                'Poppins')),
                                                    onTap: () async {
                                                      final notifier = ref.read(
                                                          settingsProvider
                                                              .notifier);
                                                      (ref.read(selectedCategoryProvider.notifier).state ==
                                                                      "Finished" &&
                                                                  notifier.getBool(
                                                                      'confirmRepeatingTasks')) ||
                                                              (ref.read(selectedCategoryProvider.notifier).state !=
                                                                      "Finished" &&
                                                                  notifier.getBool(
                                                                      'confirmFinishingTasks'))
                                                          ? showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                      AlertDialog(
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5)),
                                                                title: const Text(
                                                                    'Are you sure?',
                                                                    style: AppStyles
                                                                        .dialogBoxTitle),
                                                                content: ref
                                                                            .read(selectedCategoryProvider
                                                                                .notifier)
                                                                            .state ==
                                                                        "Finished"
                                                                    ? const Text(
                                                                        'Set tasks as unfinished?')
                                                                    : const Text(
                                                                        "Set tasks as finished?"),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(),
                                                                    child:
                                                                        const Text(
                                                                      'CANCEL',
                                                                      style: AppStyles
                                                                          .dialogBoxConfirm,
                                                                    ),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      handleConfirm(
                                                                          ref,
                                                                          context,
                                                                          task,
                                                                          selectedCategory);
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: const Text(
                                                                        'YES',
                                                                        style: AppStyles
                                                                            .dialogBoxConfirm),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : handleConfirm(
                                                              ref,
                                                              context,
                                                              task,
                                                              selectedCategory);
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                        Icons.delete),
                                                    title: const Text('Delete',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins')),
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                          title: Text(
                                                              'Delete Task?',
                                                              style: AppStyles
                                                                  .dialogBoxTitle
                                                                  .copyWith(
                                                                      fontFamily:
                                                                          'Poppins')),
                                                          content: const Text(
                                                              'Are you sure you want to delete this task?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(),
                                                              child: Text(
                                                                  'CANCEL',
                                                                  style: AppStyles
                                                                      .dialogBoxConfirm
                                                                      .copyWith(
                                                                          fontFamily:
                                                                              'Poppins')),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                ref
                                                                    .read(taskNotifierProvider
                                                                        .notifier)
                                                                    .deleteTask(
                                                                      task.id!,
                                                                      ref
                                                                          .read(
                                                                              selectedCategoryProvider.notifier)
                                                                          .state,
                                                                    );
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  'DELETE',
                                                                  style: AppStyles
                                                                      .dialogBoxCancel
                                                                      .copyWith(
                                                                          fontFamily:
                                                                              'Poppins')),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading:
                                                        const Icon(Icons.close),
                                                    title: const Text('Cancel',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins')),
                                                    onTap: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                  ),
                                                  const SizedBox(height: 16),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        onTap: () {
                                          final selectedTaskSet =
                                              ref.read(selectedTaskProvider);
                                          if (selectedTaskSet
                                              .contains(task.id)) {
                                            ref
                                                    .read(selectedTaskProvider
                                                        .notifier)
                                                    .state =
                                                HashSet<int>.from(
                                                    selectedTaskSet)
                                                  ..remove(task.id);
                                          } else {
                                            ref
                                                    .read(selectedTaskProvider
                                                        .notifier)
                                                    .state =
                                                HashSet<int>.from(
                                                    selectedTaskSet)
                                                  ..add(task.id!);
                                          }
                                          if (ref
                                              .read(
                                                  selectedTaskProvider.notifier)
                                              .state
                                              .isEmpty) {
                                            ref
                                                .read(isSelectMoreProvider
                                                    .notifier)
                                                .state = false;
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }
                              currentIndex += group.value.length;
                            }
                            return const SizedBox(height: 0);
                          },
                        ),
                ),
              ],
            ),
          ),
          // Quick task bar at the bottom, always visible
          if (!isSearching) ...[
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: _buildQuickTaskBar(context),
            ),
            if (selectedCategory != "Finished")
              Positioned(
                right: 24,
                bottom: 100,
                child: _buildFAB(context),
              ),
          ],
        ],
      ),
    );
  }

  void handleConfirm(WidgetRef ref, BuildContext context, Task task,
      String selectedCategory) async {
    await ref.read(taskNotifierProvider.notifier).updateTask(
          task.copyWith(isCompleted: !task.isCompleted),
          selectedCategory,
        );
    context.pop();
  }

  // Modern category selector as a horizontal chip list
  Widget _buildCategorySelector(WidgetRef ref, String selectedCategory) {
    final categories = ref.watch(categoryProvider);
    final allCategories = [
      "All Lists",
      ...categories.map((cat) => cat.name),
      "Finished"
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        itemCount: allCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final cat = allCategories[index];
          final isSelected = cat == selectedCategory;
          return ChoiceChip(
            label: Text(cat,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontFamily: 'Poppins',
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                )),
            selected: isSelected,
            selectedColor: Theme.of(context).colorScheme.primary,
            backgroundColor: isDark
                ? AppColors.chipUnselectedDark
                : AppColors.chipUnselectedLight,
            onSelected: (_) {
              ref.read(selectedCategoryProvider.notifier).state = cat;
              ref.read(taskNotifierProvider.notifier).filterTasks(cat);
            },
            elevation: isSelected ? 3 : 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          );
        },
      ),
    );
  }

  // Modern empty state with illustration
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/empty_state.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.inbox_rounded,
                size: 80,
                color: Colors.white24),
          ),
          const SizedBox(height: 24),
          const Text(
            "No tasks yet!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the + button to add your first task.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Quick task bar: pill-shaped, white/card color, subtle border and shadow, accent mic, clear button, readable input
  Widget _buildQuickTaskBar(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Container(
        height: 54,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.98),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.dividerColor.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon:
                  const Icon(Icons.mic, color: AppColors.accentTeal, size: 26),
              onPressed: () async {
                bool isServiceAvailable =
                    await SpeechToTextGoogleDialog.getInstance()
                        .showGoogleDialog(
                  onTextReceived: (data) {
                    setState(() {
                      _quickTask.text = data.toString();
                    });
                  },
                );
                if (!isServiceAvailable) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Service is not available'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height - 100,
                      left: 16,
                      right: 16,
                    ),
                  ));
                }
              },
            ),
            Expanded(
              child: TextField(
                controller: _quickTask,
                onSubmitted: (value) async {
                  if (value.isNotEmpty) {
                    final newTask = Task(
                        title: value,
                        dueDate: null,
                        dueTime: null,
                        category: "Default",
                        repeat: "No repeat",
                        isCompleted: false);
                    await ref
                        .read(taskNotifierProvider.notifier)
                        .addTask(newTask, "Default");
                    _quickTask.clear();
                  }
                },
                cursorColor: AppColors.accentTeal,
                style: const TextStyle(
                    color: Colors.black87, fontSize: 17, fontFamily: 'Poppins'),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter Quick Task Here",
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Poppins',
                  ),
                  suffixIcon: _quickTask.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.black38),
                          onPressed: () {
                            setState(() {
                              _quickTask.clear();
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Floating action button: clean, circular, accent color, subtle shadow, no gradient or animation
  Widget _buildFAB(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 60,
      width: 60,
      child: FloatingActionButton(
        onPressed: () => context.push('/add_task'),
        backgroundColor: color,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}

void handleOnTap(BuildContext context, String id) {
  switch (id) {
    case "Task Lists":
      context.push("/task");
      break;

    case "Settings":
      context.push("/settings");
      break;

    case "Add in Batch Mode":
      context.push("/batch");
      break;
  }
}

Map<String, List<Task>> groupTasksByDueDate(List<Task> taskList) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final startOfNextWeek =
      today.add(Duration(days: 7 - today.weekday + 1)); // Next Monday
  final endOfThisWeek =
      startOfNextWeek.subtract(const Duration(days: 1)); // This Sunday
  final endOfThisMonth = DateTime(today.year, today.month + 1, 0);
  final endOfNextMonth = DateTime(today.year, today.month + 2, 0);

  Map<String, List<Task>> grouped = {
    'Overdue': [],
    'Today': [],
    'Tomorrow': [],
    'This Week': [],
    'This Month': [],
    'Next Month': [],
    'Later': [],
    'Others': [],
  };

  for (var task in taskList) {
    if (task.dueDate == null) {
      grouped['Others']!.add(task);
      continue;
    }

    // Combine date and time
    final fullDueDateTime = task.dueTime != null
        ? DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day,
            task.dueTime!.hour, task.dueTime!.minute)
        : DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);

    if (fullDueDateTime.isBefore(now)) {
      grouped['Overdue']!.add(task);
    } else if (_isSameDay(fullDueDateTime, today)) {
      grouped['Today']!.add(task);
    } else if (_isSameDay(fullDueDateTime, tomorrow)) {
      grouped['Tomorrow']!.add(task);
    } else if (fullDueDateTime.isAfter(tomorrow) &&
        fullDueDateTime.isBefore(endOfThisWeek.add(const Duration(days: 1)))) {
      grouped['This Week']!.add(task);
    } else if (fullDueDateTime
        .isBefore(endOfThisMonth.add(const Duration(days: 1)))) {
      grouped['This Month']!.add(task);
    } else if (fullDueDateTime
        .isBefore(endOfNextMonth.add(const Duration(days: 1)))) {
      grouped['Next Month']!.add(task);
    } else {
      grouped['Later']!.add(task);
    }
  }

  for (var entry in grouped.entries) {
    if (entry.key == 'Others') continue;

    entry.value.sort((a, b) {
      DateTime getDateTime(Task task) {
        return task.dueTime != null
            ? DateTime(task.dueDate!.year, task.dueDate!.month,
                task.dueDate!.day, task.dueTime!.hour, task.dueTime!.minute)
            : DateTime(
                task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      }

      return getDateTime(a).compareTo(getDateTime(b));
    });
  }

  return grouped;
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

// Helper for drawer menu options as cards
Widget _drawerMenuCard(BuildContext context, String label, IconData icon) {
  return Card(
    color: Colors.white.withOpacity(0.08),
    elevation: 0,
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ListTile(
      leading:
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 26),
      title: Text(label,
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      hoverColor: Colors.white.withOpacity(0.06),
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.10),
    ),
  );
}
