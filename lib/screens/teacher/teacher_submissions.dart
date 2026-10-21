import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class TeacherSubmissionsPage extends StatelessWidget {
  const TeacherSubmissionsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Submissions', role: UserRole.teacher);
}
