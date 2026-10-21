import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentTransportPage extends StatelessWidget {
  const StudentTransportPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Transport', role: UserRole.student);
}
