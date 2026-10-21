import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentFinancePage extends StatelessWidget {
  const StudentFinancePage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Finance', role: UserRole.student);
}
