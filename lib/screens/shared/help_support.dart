import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'module_pages.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});
  @override Widget build(BuildContext context) => const GenericModulePage(title: 'Help & Support', role: UserRole.student);
}
