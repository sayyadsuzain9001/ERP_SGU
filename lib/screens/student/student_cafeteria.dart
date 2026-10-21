import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentCafeteriaPage extends StatelessWidget {
  const StudentCafeteriaPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Cafeteria', role: UserRole.student);
}
