import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentCareerPage extends StatelessWidget {
  const StudentCareerPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Career', role: UserRole.student);
}
