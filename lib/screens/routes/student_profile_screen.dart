import 'package:flutter/material.dart';
import '../student/student_profile.dart';

/// Route alias to keep /profile and the shell Profile tab on the same Firebase-backed screen.
class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => const StudentProfilePage();
}
