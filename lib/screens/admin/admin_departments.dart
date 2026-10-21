import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminDepartmentsPage extends StatelessWidget {
  const AdminDepartmentsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Departments', role: UserRole.admin);
}
