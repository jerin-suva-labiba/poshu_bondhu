import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/pet_model.dart';
import '../theme/app_theme.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});
  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  String _petType = 'Dog';
  String _gender = 'Male';
  DateTime? _birthday;
  String? _imagePath;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  Future<void> _pickBirthday() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _birthday = date);
  }

   Future<void> _savePet() async {
     if (_nameController.text.isEmpty || _birthday == null) {
       ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Please fill in name and birthday!')));
       return;
     }
     await DatabaseHelper.instance.insertPet(Pet(
       name: _nameController.text.trim(),
       petType: _petType,
       birthday: _birthday!.toIso8601String(),
       imagePath: _imagePath,
       breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
       gender: _gender,
     ));
     if (mounted) Navigator.pop(context);
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Pet 🐾')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
              child: _imagePath == null
                  ? Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(Icons.camera_alt, size: 36, color: AppTheme.primary),
                Text('Add Photo', style: TextStyle(color: AppTheme.primary, fontSize: 12)),
              ])
                  : null,
            ),
          ),
           const SizedBox(height: 24),
           TextField(
               controller: _nameController,
               decoration: const InputDecoration(labelText: 'Pet Name *', prefixIcon: Icon(Icons.pets))),
           const SizedBox(height: 16),
           DropdownButtonFormField<String>(
             value: _petType,
             decoration: const InputDecoration(labelText: 'Type of Pet *', prefixIcon: Icon(Icons.category)),
             items: ['Cat', 'Dog', 'Bird'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
             onChanged: (v) => setState(() => _petType = v!),
           ),
           const SizedBox(height: 16),
           TextField(
               controller: _breedController,
               decoration: const InputDecoration(labelText: 'Breed (optional)', prefixIcon: Icon(Icons.category))),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.transgender)),
            items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (v) => setState(() => _gender = v!),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickBirthday,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Icon(Icons.cake, color: AppTheme.primary),
                const SizedBox(width: 12),
                Text(
                  _birthday == null
                      ? 'Select Birthday *'
                      : 'Birthday: ${DateFormat('dd MMM yyyy').format(_birthday!)}',
                  style: TextStyle(
                      color: _birthday == null ? AppTheme.textLight : AppTheme.textDark, fontSize: 16),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
                onPressed: _savePet,
                icon: const Icon(Icons.save),
                label: const Text('Save Pet')),
          ),
        ]),
      ),
    );
  }
}