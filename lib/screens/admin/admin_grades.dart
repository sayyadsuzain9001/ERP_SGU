import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminGradesPage extends StatelessWidget {
  const AdminGradesPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Grades', role: UserRole.admin);
}
