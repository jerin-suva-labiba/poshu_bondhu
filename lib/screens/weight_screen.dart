import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/pet_model.dart';
import '../models/weight_model.dart';
import '../theme/app_theme.dart';

class WeightScreen extends StatefulWidget {
  final Pet pet;
  const WeightScreen({super.key, required this.pet});
  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  List<WeightEntry> _entries = [];
  final _weightController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getWeights(widget.pet.id!);
    setState(() => _entries = data);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _addWeight() async {
    final text = _weightController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a weight value!')));
      return;
    }
    final val = double.tryParse(text);
    if (val == null || val <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid number!')));
      return;
    }
    await DatabaseHelper.instance.insertWeight(WeightEntry(
      petId: widget.pet.id!,
      weight: val,
      date: _selectedDate.toIso8601String(),
    ));
    _weightController.clear();
    setState(() => _selectedDate = DateTime.now());
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Weight added! ✅'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));
    }
  }

  Widget _buildSummary() {
    if (_entries.length < 2) return const SizedBox();
    final first = _entries.first.weight;
    final last = _entries.last.weight;
    final diff = last - first;
    final isGain = diff >= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isGain ? const Color(0xFFFFDAC1) : const Color(0xFFB5EAD7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Text(isGain ? '📈' : '📉', style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isGain ? 'Weight Gained' : 'Weight Lost',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          Text('${diff.abs().toStringAsFixed(2)} kg since first entry',
              style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.pet.name} - Weight ⚖️')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ADD WEIGHT CARD
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Add Weight Entry',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 12),
                TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Enter weight in kg',
                    prefixIcon: const Icon(Icons.monitor_weight_outlined, color: AppTheme.primary),
                    suffixText: 'kg',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(DateFormat('dd MMM yyyy').format(_selectedDate),
                          style: const TextStyle(color: AppTheme.textDark, fontSize: 15)),
                      const Spacer(),
                      const Text('Tap to change',
                          style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _addWeight,
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                    label: const Text('Add Weight',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // GRAPH
          if (_entries.length >= 2) ...[
            const Text('Weight Progress 📈',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 10),
            _buildSummary(),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
                child: SizedBox(
                  height: 220,
                  child: LineChart(LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: _entries.asMap().entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value.weight))
                            .toList(),
                        isCurved: true,
                        color: AppTheme.primary,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                            radius: 5,
                            color: AppTheme.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primary.withOpacity(0.15),
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          getTitlesWidget: (val, meta) => Text(
                            val.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10, color: AppTheme.textLight),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (val, meta) {
                            final index = val.toInt();
                            if (index < 0 || index >= _entries.length) return const SizedBox();
                            final date = DateTime.parse(_entries[index].date);
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(DateFormat('d/M').format(date),
                                  style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (val) =>
                          FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) => spots.map((spot) {
                          final date = DateTime.parse(_entries[spot.spotIndex].date);
                          return LineTooltipItem(
                            '${spot.y} kg\n${DateFormat('dd MMM yyyy').format(date)}',
                            const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          );
                        }).toList(),
                      ),
                    ),
                  )),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ] else if (_entries.length == 1) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.yellow, borderRadius: BorderRadius.circular(16)),
              child: const Row(children: [
                Text('📊', style: TextStyle(fontSize: 24)),
                SizedBox(width: 12),
                Expanded(child: Text('Add one more entry to see the graph!',
                    style: TextStyle(color: AppTheme.textDark))),
              ]),
            ),
            const SizedBox(height: 20),
          ],

          // LOG LIST
          if (_entries.isNotEmpty) ...[
            const Text('Weight Log 📋',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _entries.length,
              itemBuilder: (context, i) {
                final e = _entries[_entries.length - 1 - i];
                final date = DateTime.parse(e.date);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: AppTheme.accent.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary,
                      child: Text('${_entries.length - i}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text('${e.weight} kg',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(date),
                        style: const TextStyle(color: AppTheme.textLight)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () async {
                        await DatabaseHelper.instance.deleteWeight(e.id!);
                        _load();
                      },
                    ),
                  ),
                );
              },
            ),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(children: [
                  Text('⚖️', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 12),
                  Text('No weight entries yet!\nAdd your first entry above 🐾',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textLight, fontSize: 16)),
                ]),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}