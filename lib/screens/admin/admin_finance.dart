import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminFinancePage extends StatelessWidget {
  const AdminFinancePage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Finance', role: UserRole.admin);
}
