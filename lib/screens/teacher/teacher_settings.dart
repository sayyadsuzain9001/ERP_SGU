import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class TeacherSettingsPage extends StatelessWidget {
  const TeacherSettingsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Settings', role: UserRole.teacher);
}
