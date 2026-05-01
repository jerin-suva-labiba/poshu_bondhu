import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/pet_model.dart';
import '../models/note_model.dart';
import '../theme/app_theme.dart';

class NotesScreen extends StatefulWidget {
  final Pet pet;
  const NotesScreen({super.key, required this.pet});
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> _notes = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getNotes(widget.pet.id!);
    setState(() => _notes = data);
  }

  Future<void> _addNote() async {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Note Title')),
          const SizedBox(height: 12),
          TextField(controller: contentCtrl,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 4),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty) return;
                await DatabaseHelper.instance.insertNote(Note(
                  petId: widget.pet.id!,
                  title: titleCtrl.text,
                  content: contentCtrl.text,
                  date: DateTime.now().toIso8601String(),
                ));
                Navigator.pop(context);
                _load();
              },
              child: const Text('Save Note'),
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.pet.name} - Notes 📝')),
      floatingActionButton: FloatingActionButton(
          onPressed: _addNote, child: const Icon(Icons.add)),
      body: _notes.isEmpty
          ? const Center(child: Text('No notes yet. Tap + to add! 📝',
          style: TextStyle(color: AppTheme.textLight)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notes.length,
        itemBuilder: (context, i) {
          final n = _notes[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: const Color(0xFFB5EAD7),
            child: ListTile(
              title: Text(n.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(n.content),
                Text(DateFormat('dd MMM yyyy').format(DateTime.parse(n.date)),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
              ]),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () async {
                  await DatabaseHelper.instance.deleteNote(n.id!);
                  _load();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}