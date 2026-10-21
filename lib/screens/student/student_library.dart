import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentLibraryPage extends StatelessWidget {
  const StudentLibraryPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Library', role: UserRole.student);
}
