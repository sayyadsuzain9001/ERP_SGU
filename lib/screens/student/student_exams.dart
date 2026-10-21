import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentExamsPage extends StatelessWidget {
  const StudentExamsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Exam Schedule', role: UserRole.student);
}
