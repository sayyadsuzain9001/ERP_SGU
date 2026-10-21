import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class TeacherMaterialsPage extends StatelessWidget {
  const TeacherMaterialsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Course Materials', role: UserRole.teacher);
}
