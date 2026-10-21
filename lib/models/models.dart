import 'package:flutter/material.dart';

enum UserRole { student, teacher, admin }

enum RecordStatus { pending, submitted, graded, overdue }

class Course {
  final String id;
  final String name;
  final String code;
  final String instructor;
  final String room;
  final String nextClass;
  final int completed;
  final int total;
  final int attendance;

  const Course({
    required this.id,
    required this.name,
    required this.code,
    required this.instructor,
    required this.room,
    required this.nextClass,
    required this.completed,
    required this.total,
    required this.attendance,
  });

  double get progress => total == 0 ? 0 : completed / total;
}

class Assignment {
  final String id;
  final String courseId;
  final String title;
  final DateTime due;
  final int marks;
  final RecordStatus status;

  const Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.due,
    required this.marks,
    required this.status,
  });
}

class Announcement {
  final String title;
  final String message;
  final String age;

  const Announcement({
    required this.title,
    required this.message,
    required this.age,
  });
}

class CalendarEvent {
  final String title;
  final DateTime date;
  final String time;
  final String category;

  const CalendarEvent({
    required this.title,
    required this.date,
    required this.time,
    required this.category,
  });
}

class AttendancePoint {
  final String label;
  final double value;

  const AttendancePoint(this.label, this.value);
}

class CampusService {
  final String id;
  final String name;
  final String description;
  final String location;
  final String hours;
  final String email;
  final String phone;
  final IconData icon;

  const CampusService({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.hours,
    required this.email,
    required this.phone,
    required this.icon,
  });
}

class CampusEventItem {
  final String id;
  final String title;
  final String dateLabel;
  final String time;
  final String location;
  final String category;
  final String description;
  final IconData icon;

  const CampusEventItem({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.time,
    required this.location,
    required this.category,
    required this.description,
    required this.icon,
  });
}

class TimetableEntry {
  final String day;
  final String subject;
  final String time;
  final String room;
  final String instructor;

  const TimetableEntry({
    required this.day,
    required this.subject,
    required this.time,
    required this.room,
    required this.instructor,
  });
}
