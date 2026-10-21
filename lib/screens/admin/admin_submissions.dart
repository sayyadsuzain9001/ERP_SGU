import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminSubmissionsPage extends StatelessWidget {
  const AdminSubmissionsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Submissions', role: UserRole.admin);
}
