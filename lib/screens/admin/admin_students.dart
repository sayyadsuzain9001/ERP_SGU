import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminStudentsPage extends StatelessWidget {
  const AdminStudentsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Students', role: UserRole.admin);
}
