import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentDocumentsPage extends StatelessWidget {
  const StudentDocumentsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Documents', role: UserRole.student);
}
