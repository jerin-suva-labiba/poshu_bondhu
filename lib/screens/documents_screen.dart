import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/pet_model.dart';
import '../models/document_model.dart';
import '../theme/app_theme.dart';

class DocumentsScreen extends StatefulWidget {
  final Pet pet;
  const DocumentsScreen({super.key, required this.pet});
  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<DocumentEntry> _entries = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getDocuments(widget.pet.id!);
    setState(() => _entries = data);
  }

  Future<void> _addDocument() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null || result.files.single.path == null) return;
    final notesCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Note for Document'),
        content: TextField(controller: notesCtrl, decoration: const InputDecoration(hintText: 'Optional notes...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.insertDocument(DocumentEntry(
                petId: widget.pet.id!, fileName: result.files.single.name,
                filePath: result.files.single.path!,
                notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
                date: DateTime.now().toIso8601String(),
              ));
              Navigator.pop(context);
              _load();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.pet.name} - Documents 📄')),
      floatingActionButton: FloatingActionButton(onPressed: _addDocument, child: const Icon(Icons.add)),
      body: _entries.isEmpty
          ? const Center(child: Text('No documents yet. Tap + to add! 📄', style: TextStyle(color: AppTheme.textLight)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        itemBuilder: (context, i) {
          final d = _entries[i];
          return Card(
            color: const Color(0xFFE2F0CB),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Text('📄', style: TextStyle(fontSize: 28)),
              title: Text(d.fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (d.notes != null) Text(d.notes!),
                Text(DateFormat('dd MMM yyyy').format(DateTime.parse(d.date)),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
              ]),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  icon: const Icon(Icons.open_in_new, color: AppTheme.primary),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: Text(d.fileName)),
                      body: PDFView(filePath: d.filePath),
                    ),
                  )),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async { await DatabaseHelper.instance.deleteDocument(d.id!); _load(); },
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}