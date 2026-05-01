import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/pet_model.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import 'weight_screen.dart';
import 'notes_screen.dart';
import 'vaccine_screen.dart';
import 'deworming_screen.dart';
import 'documents_screen.dart';
import 'memories_screen.dart';

class PetProfileScreen extends StatefulWidget {
  final Pet pet;
  const PetProfileScreen({super.key, required this.pet});
  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  late Pet _pet;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await _updatePetImage(picked.path);
    }
  }

  Future<void> _updatePetImage(String newImagePath) async {
    _pet.imagePath = newImagePath;
    await DatabaseHelper.instance.updatePet(_pet);
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet photo updated! 📸')),
      );
    }
  }

   @override
   Widget build(BuildContext context) {
     final features = [
       {'icon': '⚖️', 'label': 'Weight',    'color': const Color(0xFFFFDAC1)},
       {'icon': '📝', 'label': 'Notes',     'color': const Color(0xFFB5EAD7)},
       {'icon': '💉', 'label': 'Vaccine',   'color': const Color(0xFFFFB3C6)},
       {'icon': '🐛', 'label': 'Deworming', 'color': const Color(0xFFFFF9C4)},
       {'icon': '📄', 'label': 'Documents', 'color': const Color(0xFFE2F0CB)},
       {'icon': '📸', 'label': 'Memories',  'color': const Color(0xFFFFD4E5)},
       {'icon': '🔔', 'label': 'Reminder',  'color': const Color(0xFFC7CEEA)},
     ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, Color(0xFFFFDAC1)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage: _pet.imagePath != null
                                  ? FileImage(File(_pet.imagePath!))
                                  : null,
                              child: _pet.imagePath == null
                                  ? const Text('🐾', style: TextStyle(fontSize: 40))
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_pet.name,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(_pet.age,
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pet Features',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: features.length,
                    itemBuilder: (context, i) {
                      final f = features[i];
                      return GestureDetector(
                        onTap: () => _navigateTo(context, f['label'] as String),
                        child: Container(
                          decoration: BoxDecoration(
                            color: f['color'] as Color,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3))
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(f['icon'] as String,
                                  style: const TextStyle(fontSize: 40)),
                              const SizedBox(height: 8),
                              Text(f['label'] as String,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String label) {
    Widget? screen;
    switch (label) {
      case 'Weight':
        screen = WeightScreen(pet: _pet);
        break;
      case 'Notes':
        screen = NotesScreen(pet: _pet);
        break;
      case 'Vaccine':
        screen = VaccineScreen(pet: _pet);
        break;
      case 'Deworming':
        screen = DewormingScreen(pet: _pet);
        break;
      case 'Documents':
        screen = DocumentsScreen(pet: _pet);
        break;
      case 'Memories':
        screen = MemoriesScreen(pet: _pet);
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
  }
}