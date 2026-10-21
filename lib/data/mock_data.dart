import 'package:flutter/material.dart';

import '../models/models.dart';

class MockData {
  MockData._();
  static final MockData i = MockData._();

  final String studentName = 'Suzain Mudabbir Sayyad';
  final String studentId = 'I26043300';
  final String programme = 'B.Tech Artificial Intelligence & Machine Learning';
  final String email = 'suzain@example.edu';
  final String semester = 'Semester 6';
  final double cgpa = 8.35;
  final int overallAttendance = 82;
  final int credits = 96;

  final List<Course> courses = const [
    Course(id: 'ml', name: 'Machine Learning', code: 'PRG4206', instructor: 'Dr. A. Patil', room: 'Room 305', nextClass: 'Today • 11:30 AM', completed: 3, total: 5, attendance: 84),
    Course(id: 'dl', name: 'Deep Learning', code: 'PRG4207', instructor: 'Dr. R. Kulkarni', room: 'Lab 204', nextClass: 'Tomorrow • 09:00 AM', completed: 2, total: 6, attendance: 83),
    Course(id: 'mobile', name: 'Cross-Platform Mobile Application', code: 'NET4207', instructor: 'Prof. S. Joshi', room: 'Lab 101', nextClass: 'Today • 10:00 AM', completed: 1, total: 5, attendance: 88),
    Course(id: 'cv', name: 'Computer Vision', code: 'AIML4204', instructor: 'Dr. P. Deshmukh', room: 'Lab 101', nextClass: 'Friday • 02:00 PM', completed: 1, total: 5, attendance: 86),
  ];

  final List<Assignment> assignments = [
    Assignment(id: 'a1', courseId: 'dl', title: 'Deep Learning Assignment', due: DateTime(2026, 9, 25, 23, 59), marks: 20, status: RecordStatus.pending),
    Assignment(id: 'a2', courseId: 'ml', title: 'Machine Learning Report', due: DateTime(2026, 9, 29, 23, 59), marks: 30, status: RecordStatus.pending),
    Assignment(id: 'a3', courseId: 'mobile', title: 'Mobile Application Prototype', due: DateTime(2026, 10, 2, 23, 59), marks: 25, status: RecordStatus.submitted),
  ];

  final List<Announcement> announcements = const [
    Announcement(title: 'Assignment Deadline Reminder', message: 'Deep Learning assignment due on 25 Sep.', age: '2 hours ago'),
    Announcement(title: 'Lab Session Update', message: 'Lab 204 will be available for the session.', age: '1 day ago'),
    Announcement(title: 'Mid-Semester Examination', message: 'Schedule has been released. Check calendar.', age: '2 days ago'),
  ];

  final List<CalendarEvent> events = [
    CalendarEvent(title: 'Week 4 Lab', date: DateTime(2026, 9, 24), time: '02:00 PM', category: 'Events'),
    CalendarEvent(title: 'Machine Learning - Data Mining', date: DateTime(2026, 9, 24), time: '11:30 AM', category: 'Classes'),
    CalendarEvent(title: 'Deep Learning Assignment', date: DateTime(2026, 9, 25), time: '11:59 PM', category: 'Deadlines'),
    CalendarEvent(title: 'Mid-Semester Review', date: DateTime(2026, 9, 30), time: '02:00 PM', category: 'Events'),
  ];

  final List<AttendancePoint> attendanceTrend = const [
    AttendancePoint('Mon', .78), AttendancePoint('Tue', .80), AttendancePoint('Wed', .79),
    AttendancePoint('Thu', .82), AttendancePoint('Fri', .81), AttendancePoint('Sat', .82),
  ];

  Course course(String id) => courses.firstWhere((item) => item.id == id, orElse: () => courses.first);
}

extension CampusRouteMockData on MockData {
  List<CampusService> get campusServices => const [
        CampusService(
          id: 'accommodation',
          name: 'Accommodation Office',
          description: 'Hostel allocation, room maintenance, accommodation enquiries and residence support.',
          location: 'Student Centre, Level 2',
          hours: '8:30 AM – 5:00 PM',
          email: 'housing@sgu.edu.in',
          phone: '+91 231 260 0000',
          icon: Icons.home_work_outlined,
        ),
        CampusService(
          id: 'counselling',
          name: 'Student Counselling',
          description: 'Personal, academic and wellbeing support for students who need confidential guidance.',
          location: 'Student Wellness Centre',
          hours: '9:00 AM – 4:30 PM',
          email: 'counselling@sgu.edu.in',
          phone: '+91 231 260 0011',
          icon: Icons.support_outlined,
        ),
        CampusService(
          id: 'it-helpdesk',
          name: 'IT Helpdesk',
          description: 'Help with student accounts, Wi-Fi, learning systems, software and campus technology.',
          location: 'IT Services Block, Ground Floor',
          hours: '8:00 AM – 6:00 PM',
          email: 'helpdesk@sgu.edu.in',
          phone: '+91 231 260 0022',
          icon: Icons.computer_outlined,
        ),
        CampusService(
          id: 'library',
          name: 'Library Services',
          description: 'Library membership, book loans, digital resources and research support.',
          location: 'Central Library',
          hours: '8:00 AM – 8:00 PM',
          email: 'library@sgu.edu.in',
          phone: '+91 231 260 0033',
          icon: Icons.local_library_outlined,
        ),
        CampusService(
          id: 'career',
          name: 'Career Services',
          description: 'Internships, placements, career counselling, CV support and employer activities.',
          location: 'Career Development Centre',
          hours: '9:00 AM – 5:30 PM',
          email: 'careers@sgu.edu.in',
          phone: '+91 231 260 0044',
          icon: Icons.work_outline,
        ),
      ];

  List<CampusEventItem> get campusEventItems => const [
        CampusEventItem(
          id: 'tech-fest',
          title: 'SGU Tech Fest 2026',
          dateLabel: '18 October 2026',
          time: '10:00 AM – 5:00 PM',
          location: 'Main Auditorium',
          category: 'University Event',
          description: 'A student technology festival with project showcases, coding activities, demonstrations and competitions.',
          icon: Icons.memory_outlined,
        ),
        CampusEventItem(
          id: 'career-day',
          title: 'Career and Internship Day',
          dateLabel: '22 October 2026',
          time: '9:30 AM – 3:30 PM',
          location: 'Convention Hall',
          category: 'Career',
          description: 'Meet recruiters, attend career sessions and explore internship and placement opportunities.',
          icon: Icons.business_center_outlined,
        ),
        CampusEventItem(
          id: 'sports-day',
          title: 'Inter-Department Sports Day',
          dateLabel: '28 October 2026',
          time: '8:00 AM – 4:00 PM',
          location: 'University Sports Ground',
          category: 'Sports',
          description: 'A full-day university sports programme with department teams and student activities.',
          icon: Icons.sports_soccer_outlined,
        ),
      ];

  List<TimetableEntry> get timetableEntries => const [
        TimetableEntry(
          day: 'Monday',
          subject: 'Deep Learning',
          time: '09:00 AM – 10:00 AM',
          room: 'Lab 204',
          instructor: 'Dr. R. Kulkarni',
        ),
        TimetableEntry(
          day: 'Monday',
          subject: 'Machine Learning',
          time: '11:30 AM – 01:00 PM',
          room: 'Room 305',
          instructor: 'Dr. A. Patil',
        ),
        TimetableEntry(
          day: 'Tuesday',
          subject: 'Computer Vision',
          time: '02:00 PM – 04:00 PM',
          room: 'Lab 101',
          instructor: 'Dr. P. Deshmukh',
        ),
        TimetableEntry(
          day: 'Wednesday',
          subject: 'Cross-Platform Mobile Application',
          time: '10:00 AM – 12:00 PM',
          room: 'Lab 101',
          instructor: 'Prof. S. Joshi',
        ),
        TimetableEntry(
          day: 'Thursday',
          subject: 'Project Discussion',
          time: '04:30 PM – 05:30 PM',
          room: 'Online',
          instructor: 'Project Supervisor',
        ),
      ];
}
