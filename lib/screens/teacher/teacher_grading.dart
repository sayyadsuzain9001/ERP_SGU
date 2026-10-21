import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class TeacherGradingPage extends StatelessWidget {
  const TeacherGradingPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Grading', role: UserRole.teacher);
}
