import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentHostelPage extends StatelessWidget {
  const StudentHostelPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Hostel', role: UserRole.student);
}
