import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/pet_model.dart';
import '../models/vaccine_model.dart';
import '../notifications/notification_helper.dart';
import '../theme/app_theme.dart';

class VaccineScreen extends StatefulWidget {
  final Pet pet;
  const VaccineScreen({super.key, required this.pet});
  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> {
  List<VaccineEntry> _entries = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getVaccines(widget.pet.id!);
    setState(() => _entries = data);
  }

  Future<void> _addVaccine() async {
    final nameCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime? selectedDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Add Vaccine 💉',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Vaccine Name')),
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
                      ? 'Last Vaccination Date'
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
                         const SnackBar(content: Text('Please enter vaccine name!')),
                       );
                     }
                     return;
                   }
                   if (selectedDate == null) {
                     if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Please select vaccination date!')),
                       );
                     }
                     return;
                   }
                    try {
                      final nextDate = DateTime(
                          selectedDate!.year + 1, selectedDate!.month, selectedDate!.day);
                      await DatabaseHelper.instance.insertVaccine(VaccineEntry(
                        petId: widget.pet.id!,
                        vaccineName: nameCtrl.text.trim(),
                        lastDate: selectedDate!.toIso8601String(),
                        nextDate: nextDate.toIso8601String(),
                        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                      ));
                      // Only schedule reminder if next date is in the future
                      if (nextDate.isAfter(DateTime.now())) {
                        await NotificationHelper.scheduleReminder(
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          title: '💉 Vaccine Due - ${widget.pet.name}',
                          body: '${nameCtrl.text} is due today!',
                          scheduledDate: nextDate,
                        );
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vaccine saved & reminder set! 💉')),
                        );
                        Navigator.pop(context);
                        _load();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving vaccine: $e')),
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
      appBar: AppBar(title: Text('${widget.pet.name} - Vaccines 💉')),
      floatingActionButton: FloatingActionButton(onPressed: _addVaccine, child: const Icon(Icons.add)),
      body: _entries.isEmpty
          ? const Center(child: Text('No vaccines logged yet. Tap + to add! 💉',
          style: TextStyle(color: AppTheme.textLight)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        itemBuilder: (context, i) {
          final v = _entries[i];
          final next = DateTime.parse(v.nextDate);
          final isUpcoming = next.isAfter(DateTime.now());
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: const Color(0xFFFFB3C6),
            child: ListTile(
              leading: const Text('💉', style: TextStyle(fontSize: 28)),
              title: Text(v.vaccineName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Last: ${DateFormat('dd MMM yyyy').format(DateTime.parse(v.lastDate))}'),
                Text('Next: ${DateFormat('dd MMM yyyy').format(next)}',
                    style: TextStyle(
                        color: isUpcoming ? Colors.green.shade700 : Colors.red.shade700,
                        fontWeight: FontWeight.bold)),
              ]),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () async {
                  await DatabaseHelper.instance.deleteVaccine(v.id!);
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