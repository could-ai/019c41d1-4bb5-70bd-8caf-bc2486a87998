import 'package:flutter/material.dart';

class TimeEntry {
  String id;
  DateTime date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String description;

  TimeEntry({
    required this.id,
    required this.date,
    this.startTime,
    this.endTime,
    this.description = '',
  });

  // Calculate duration in hours
  double get duration {
    if (startTime == null || endTime == null) return 0.0;
    
    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;
    
    int diff = endMinutes - startMinutes;
    
    // Handle overnight (e.g. 11 PM to 1 AM)
    if (diff < 0) {
      diff += 24 * 60;
    }
    
    return diff / 60.0;
  }
}
