import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Notifications', role: UserRole.admin);
}
