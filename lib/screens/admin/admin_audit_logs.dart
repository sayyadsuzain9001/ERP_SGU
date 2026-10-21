import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminAuditLogsPage extends StatelessWidget {
  const AdminAuditLogsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Audit Logs', role: UserRole.admin);
}
