import 'package:flutter/material.dart';
import 'dart:io';
import '../database/database_helper.dart';
import '../models/pet_model.dart';
import '../theme/app_theme.dart';
import 'add_pet_screen.dart';
import 'pet_profile_screen.dart';
import 'calendar_screen.dart';
import 'vet_shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Pet> _pets = [];

  @override
  void initState() { super.initState(); _loadPets(); }

  Future<void> _loadPets() async {
    final pets = await DatabaseHelper.instance.getAllPets();
    setState(() => _pets = pets);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [_buildHomeTab(), const CalendarScreen(), const VetShopScreen()];
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary.withOpacity(0.3),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month_rounded), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.local_hospital_rounded), label: 'Vet/Shop'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('পোষা বন্ধু 🐾',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 60, bottom: 16),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.pets, color: AppTheme.primary, size: 28),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(children: [
                const Text('Current Pets',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(width: 8),
                Text('(${_pets.length})', style: const TextStyle(color: AppTheme.textLight, fontSize: 16)),
              ]),
            ),
          ),
          _pets.isEmpty
              ? SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(children: [
                  const Text('🐱', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 12),
                  const Text('No pets yet!\nTap + to add your first pet 🐾',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textLight, fontSize: 16)),
                ]),
              ),
            ),
          )
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPetCard(_pets[index]),
              childCount: _pets.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPetScreen()));
          _loadPets();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Pet'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => PetProfileScreen(pet: pet)));
          _loadPets();
        },
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primary.withOpacity(0.2),
                backgroundImage: pet.imagePath != null ? FileImage(File(pet.imagePath!)) : null,
                child: pet.imagePath == null ? const Text('🐾', style: TextStyle(fontSize: 30)) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(pet.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  Text('Age: ${pet.age}', style: const TextStyle(color: AppTheme.textLight)),
                  if (pet.breed != null)
                    Text('Breed: ${pet.breed}',
                        style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
                ]),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.primary),
            ]),
          ),
        ),
      ),
    );
  }
}