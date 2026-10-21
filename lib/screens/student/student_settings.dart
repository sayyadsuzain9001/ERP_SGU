import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentSettingsPage extends StatelessWidget {
  const StudentSettingsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Settings', role: UserRole.student);
}
