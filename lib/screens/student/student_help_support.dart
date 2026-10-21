import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentHelpSupportPage extends StatelessWidget {
  const StudentHelpSupportPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Help & Support', role: UserRole.student);
}
