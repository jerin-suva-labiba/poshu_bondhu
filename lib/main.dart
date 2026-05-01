import 'package:flutter/material.dart';
import 'notifications/notification_helper.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.init();
  runApp(const PoshaBondhuApp());
}

class PoshaBondhuApp extends StatelessWidget {
  const PoshaBondhuApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'পোষা বন্ধু',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const Center(child: Text('Loading...')),
    );
  }
}