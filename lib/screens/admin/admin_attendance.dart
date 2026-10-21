import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminAttendancePage extends StatelessWidget {
  const AdminAttendancePage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Attendance', role: UserRole.admin);
}
