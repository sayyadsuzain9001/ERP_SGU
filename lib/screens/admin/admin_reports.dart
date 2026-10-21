import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Reports', role: UserRole.admin);
}
