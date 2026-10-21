import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'module_pages.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override Widget build(BuildContext context) => const GenericModulePage(title: 'Settings', role: UserRole.student);
}
