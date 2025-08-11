import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list/providers/settings_provider.dart';
import 'package:todo_list/routes/routes.dart';
import 'package:todo_list/services/foreground_service_helper.dart';
import 'package:todo_list/services/notification_helper.dart';
import 'package:todo_list/utils/app_theme.dart';

const platform = MethodChannel('com.example.todo_list/navigation');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupNavigationChannel();
  NotificationService().initializeNotifications();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

void _setupNavigationChannel() {
  platform.setMethodCallHandler((call) async {
    if (call.method == 'navigateTo') {
      final String route = call.arguments;
      // Use the router instance to navigate
      router.go(route); // Or router.push(route) depending on your navigation logic
    }
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = settings['darkMode'] == 'true';
    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: appThemeLight, // Light theme
      darkTheme: appThemeDark, // Dark theme
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
