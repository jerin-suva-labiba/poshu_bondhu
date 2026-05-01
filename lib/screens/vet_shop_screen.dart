import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VetShopScreen extends StatelessWidget {
  const VetShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Vet & Shop 🏥')),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🏗️', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 20),
          const Text('Coming Soon!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 10),
          Text("We're working on something\namazing for your pets! 🐾",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppTheme.textLight)),
        ]),
      ),
    );
  }
}