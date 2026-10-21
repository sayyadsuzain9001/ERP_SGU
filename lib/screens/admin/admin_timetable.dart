import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminTimetablePage extends StatelessWidget {
  const AdminTimetablePage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Timetable', role: UserRole.admin);
}
