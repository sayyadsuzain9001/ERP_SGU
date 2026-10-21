import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminAcademicCalendarPage extends StatelessWidget {
  const AdminAcademicCalendarPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Academic Calendar', role: UserRole.admin);
}
