import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentClubsPage extends StatelessWidget {
  const StudentClubsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Clubs', role: UserRole.student);
}
