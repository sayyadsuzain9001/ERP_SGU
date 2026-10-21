import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminStaffPage extends StatelessWidget {
  const AdminStaffPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Staff', role: UserRole.admin);
}
