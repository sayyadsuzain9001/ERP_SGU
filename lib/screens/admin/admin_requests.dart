import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminRequestsPage extends StatelessWidget {
  const AdminRequestsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Requests', role: UserRole.admin);
}
