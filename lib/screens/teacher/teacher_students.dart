import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class TeacherStudentsPage extends StatelessWidget {
  const TeacherStudentsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Students', role: UserRole.teacher);
}
