import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class TeacherAnalyticsPage extends StatelessWidget {
  const TeacherAnalyticsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Analytics', role: UserRole.teacher);
}
