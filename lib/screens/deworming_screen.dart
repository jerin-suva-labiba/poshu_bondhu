import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/pet_model.dart';
import '../models/deworming_model.dart';
import '../notifications/notification_helper.dart';
import '../theme/app_theme.dart';

class DewormingScreen extends StatefulWidget {
  final Pet pet;
  const DewormingScreen({super.key, required this.pet});
  @override
  State<DewormingScreen> createState() => _DewormingScreenState();
}

class _DewormingScreenState extends State<DewormingScreen> {
  List<DewormingEntry> _entries = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getDeworming(widget.pet.id!);
    setState(() => _entries = data);
  }

  Future<void> _addEntry() async {
    final nameCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime? selectedDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Add Deworming 🐛',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Medicine Name')),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now());
                if (d != null) setLocal(() => selectedDate = d);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.calendar_today, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Text(selectedDate == null
                      ? 'Last Deworming Date'
                      : DateFormat('dd MMM yyyy').format(selectedDate!)),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            TextField(controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes (optional)')),
            const SizedBox(height: 16),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: () async {
                   if (nameCtrl.text.trim().isEmpty) {
                     if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Please enter medicine name!')),
                       );
                     }
                     return;
                   }
                   if (selectedDate == null) {
                     if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Please select deworming date!')),
                       );
                     }
                     return;
                   }
                    try {
                      final nextDate = DateTime(
                          selectedDate!.year, selectedDate!.month + 3, selectedDate!.day);
                      await DatabaseHelper.instance.insertDeworming(DewormingEntry(
                        petId: widget.pet.id!,
                        medicineName: nameCtrl.text.trim(),
                        lastDate: selectedDate!.toIso8601String(),
                        nextDate: nextDate.toIso8601String(),
                        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                      ));
                      // Only schedule reminder if next date is in the future
                      if (nextDate.isAfter(DateTime.now())) {
                        await NotificationHelper.scheduleReminder(
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          title: '🐛 Deworming Due - ${widget.pet.name}',
                          body: '${nameCtrl.text} is due today!',
                          scheduledDate: nextDate,
                        );
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Deworming saved & reminder set! 🐛')),
                        );
                        Navigator.pop(context);
                        _load();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving deworming: $e')),
                        );
                      }
                    }
                 },
                 child: const Text('Save & Set Reminder'),
               ),
             ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.pet.name} - Deworming 🐛')),
      floatingActionButton: FloatingActionButton(
          onPressed: _addEntry, child: const Icon(Icons.add)),
      body: _entries.isEmpty
          ? const Center(child: Text('No deworming logged yet. Tap + to add!',
          style: TextStyle(color: AppTheme.textLight)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        itemBuilder: (context, i) {
          final d = _entries[i];
          final next = DateTime.parse(d.nextDate);
          return Card(
            color: const Color(0xFFFFF9C4),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Text('🐛', style: TextStyle(fontSize: 28)),
              title: Text(d.medicineName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Last: ${DateFormat('dd MMM yyyy').format(DateTime.parse(d.lastDate))}'),
                Text('Next: ${DateFormat('dd MMM yyyy').format(next)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
              ]),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () async {
                  await DatabaseHelper.instance.deleteDeworming(d.id!);
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