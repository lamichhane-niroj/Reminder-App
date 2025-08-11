import 'package:go_router/go_router.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/pages/add_batch_mode.dart';
import 'package:todo_list/pages/add_new_task.dart';
import 'package:todo_list/pages/edit_task.dart';
import 'package:todo_list/pages/home_page.dart';
import 'package:todo_list/pages/settings.dart';
import 'package:todo_list/pages/task_list_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/add_task',
      builder: (context, state) {
        final prefillText = state.extra as String?;
        return AddNewTask(prefillText: prefillText);
      },
    ),
    GoRoute(path: '/task', builder: (context, state) => const TaskListPage()),
    GoRoute(
        path: '/settings', builder: (context, state) => const SettingsPage()),
    GoRoute(path: '/batch', builder: (context, state) => AddBatchModePage()),
    GoRoute(
      path: '/edit',
      builder: (context, state) {
        final task = state.extra as Task;
        return EditTask(task: task);
      },
    ),
  ],
);
