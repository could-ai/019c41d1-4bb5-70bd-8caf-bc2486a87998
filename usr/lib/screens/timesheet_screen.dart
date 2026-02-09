import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // We'll use basic formatting manually if intl isn't available, but usually it is. I'll write helper functions to be safe.
import '../models/time_entry.dart';

class TimesheetScreen extends StatefulWidget {
  const TimesheetScreen({super.key});

  @override
  State<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen> {
  final List<TimeEntry> _entries = [];
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add an initial empty row
    _addEntry();
  }

  void _addEntry() {
    setState(() {
      _entries.add(TimeEntry(
        id: DateTime.now().toIso8601String(),
        date: DateTime.now(),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      ));
    });
  }

  void _removeEntry(String id) {
    setState(() {
      _entries.removeWhere((entry) => entry.id == id);
    });
  }

  double _calculateTotalHours() {
    return _entries.fold(0.0, (sum, entry) => sum + entry.duration);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "--:--";
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Future<void> _pickDate(TimeEntry entry) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: entry.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        entry.date = picked;
      });
    }
  }

  Future<void> _pickTime(TimeEntry entry, bool isStart) async {
    final initial = isStart ? entry.startTime : entry.endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          entry.startTime = picked;
        } else {
          entry.endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timesheet Entry'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Timesheet saved (mock)')),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                const SizedBox(width: 120, child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(width: 100, child: Text('Start', style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(width: 100, child: Text('End', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(child: Text('Description / Task', style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(width: 80, child: Text('Hours', style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(width: 50, child: Text('')),
              ],
            ),
          ),
          
          // List of Entries
          Expanded(
            child: ListView.separated(
              itemCount: _entries.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: index % 2 == 0 ? Colors.white : Colors.grey[50],
                  child: Row(
                    children: [
                      // Date Picker
                      SizedBox(
                        width: 120,
                        child: InkWell(
                          onTap: () => _pickDate(entry),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(_formatDate(entry.date)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Start Time
                      SizedBox(
                        width: 100,
                        child: InkWell(
                          onTap: () => _pickTime(entry, true),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(_formatTime(entry.startTime)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // End Time
                      SizedBox(
                        width: 100,
                        child: InkWell(
                          onTap: () => _pickTime(entry, false),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_filled, size: 16, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(_formatTime(entry.endTime)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Description
                      Expanded(
                        child: TextFormField(
                          initialValue: entry.description,
                          decoration: const InputDecoration(
                            hintText: 'What did you work on?',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (value) => entry.description = value,
                        ),
                      ),
                      
                      // Duration
                      SizedBox(
                        width: 80,
                        child: Text(
                          entry.duration.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                      // Delete Action
                      SizedBox(
                        width: 50,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => _removeEntry(entry.id),
                          tooltip: 'Remove row',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Footer / Summary
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Entries: ${_entries.length}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Total Hours: ${_calculateTotalHours().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEntry,
        icon: const Icon(Icons.add),
        label: const Text('Add Row'),
      ),
    );
  }
}
