import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/pet_model.dart';
import '../models/memory_model.dart';
import '../theme/app_theme.dart';

class MemoriesScreen extends StatefulWidget {
  final Pet pet;
  const MemoriesScreen({super.key, required this.pet});
  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  List<Memory> _memories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getMemories(widget.pet.id!);
    setState(() => _memories = data);
  }

  Future<void> _addMemory() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final now = DateTime.now();
      final memory = Memory(
        petId: widget.pet.id!,
        imagePath: picked.path,
        timestamp: now.toIso8601String(),
      );
      await DatabaseHelper.instance.insertMemory(memory);
      _load();
    }
  }

  Future<void> _deleteMemory(Memory memory) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Memory?'),
        content: const Text('This memory will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && memory.id != null) {
      await DatabaseHelper.instance.deleteMemory(memory.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memories 📸')),
      body: _memories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('📷', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 16),
                  Text('No memories yet!\nAdd some precious moments 💕',
                      textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textLight, fontSize: 16)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _memories.length,
              itemBuilder: (context, index) {
                final memory = _memories[index];
                final date = DateTime.parse(memory.timestamp);
                final formattedDate = DateFormat('dd MMM yyyy\nhh:mm a').format(date);
                return GestureDetector(
                  onLongPress: () => _deleteMemory(memory),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      // ignore: deprecated_member_use
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(memory.imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppTheme.background,
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 40, color: AppTheme.textLight),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                // ignore: deprecated_member_use
                                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMemory,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Add Memory'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }
}








