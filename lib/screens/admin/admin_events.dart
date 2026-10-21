import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminEventsPage extends StatelessWidget {
  const AdminEventsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Events', role: UserRole.admin);
}
