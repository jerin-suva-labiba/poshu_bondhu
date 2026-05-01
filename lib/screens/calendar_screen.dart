import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  Map<String, List<Map<String, String>>> _reminders = {};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getAllReminders();
    setState(() => _reminders = data);
  }

  List<Map<String, String>> get _selectedReminders {
    final key = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _reminders.entries
        .where((e) => e.key.startsWith(key))
        .expand((e) => e.value)
        .toList();
  }

  bool _hasReminder(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return _reminders.keys.any((k) => k.startsWith(key));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Calendar 📅')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(
              onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1)),
              icon: const Icon(Icons.chevron_left),
            ),
            Text(DateFormat('MMMM yyyy').format(_currentMonth),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            IconButton(
              onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1)),
              icon: const Icon(Icons.chevron_right),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
                .map((d) => Expanded(child: Center(
                child: Text(d, style: const TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.bold, fontSize: 12)))))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        _buildCalendarGrid(),
        const Divider(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Reminders for ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _selectedReminders.isEmpty
              ? const Center(child: Text('No reminders for this day 🎉', style: TextStyle(color: AppTheme.textLight)))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _selectedReminders.length,
            itemBuilder: (context, i) {
              final r = _selectedReminders[i];
              return Card(
                color: const Color(0xFFC7CEEA),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Text(r['type']!.split(' ')[0], style: const TextStyle(fontSize: 28)),
                  title: Text(r['pet']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${r['type']} — ${r['detail']}'),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startWeekday = firstDay.weekday % 7;
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final rows = ((startWeekday + daysInMonth) / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: List.generate(rows, (row) => Row(
          children: List.generate(7, (col) {
            final day = row * 7 + col - startWeekday + 1;
            if (day < 1 || day > daysInMonth) return const Expanded(child: SizedBox(height: 44));
            final date = DateTime(_currentMonth.year, _currentMonth.month, day);
            final isSelected = _selectedDate.day == day && _selectedDate.month == _currentMonth.month && _selectedDate.year == _currentMonth.year;
            final isToday = DateTime.now().day == day && DateTime.now().month == _currentMonth.month && DateTime.now().year == _currentMonth.year;
            final hasReminder = _hasReminder(date);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  height: 44,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : isToday ? AppTheme.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('$day', style: TextStyle(fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppTheme.textDark)),
                    if (hasReminder) Container(width: 5, height: 5,
                        decoration: BoxDecoration(
                            color: isSelected ? Colors.white : AppTheme.primary, shape: BoxShape.circle)),
                  ]),
                ),
              ),
            );
          }),
        )),
      ),
    );
  }
}