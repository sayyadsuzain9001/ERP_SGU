import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentTasksPage extends StatelessWidget {
  const StudentTasksPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Tasks', role: UserRole.student);
}
