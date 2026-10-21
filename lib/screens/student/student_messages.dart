import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentMessagesPage extends StatelessWidget {
  const StudentMessagesPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Messages', role: UserRole.student);
}
