import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class TeacherAssignmentsPage extends StatelessWidget {
  const TeacherAssignmentsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Assignments', role: UserRole.teacher);
}
