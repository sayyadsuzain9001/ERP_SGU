import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentResultsPage extends StatelessWidget {
  const StudentResultsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Results', role: UserRole.student);
}
