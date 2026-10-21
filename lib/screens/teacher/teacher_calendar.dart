import 'package:flutter/material.dart';
import '../shared/calendar.dart';

/// Teacher Calendar tab uses the same Firebase-backed event calendar.
class TeacherCalendarPage extends StatelessWidget {
  const TeacherCalendarPage({super.key});
  @override
  Widget build(BuildContext context) => const CalendarPage();
}
