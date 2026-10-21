import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminAssignmentsPage extends StatelessWidget {
  const AdminAssignmentsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Assignments', role: UserRole.admin);
}
