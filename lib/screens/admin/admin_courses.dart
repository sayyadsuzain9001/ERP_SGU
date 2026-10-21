import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminCoursesPage extends StatelessWidget {
  const AdminCoursesPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Courses', role: UserRole.admin);
}
