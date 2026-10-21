import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentProgressPage extends StatelessWidget {
  const StudentProgressPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Academic Progress', role: UserRole.student);
}
