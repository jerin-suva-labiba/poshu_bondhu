import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifications/notification_helper.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.init();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  runApp(PoshaBondhuApp(isLoggedIn: isLoggedIn));
}

class PoshaBondhuApp extends StatelessWidget {
  final bool isLoggedIn;
  const PoshaBondhuApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'পোষা বন্ধু',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
