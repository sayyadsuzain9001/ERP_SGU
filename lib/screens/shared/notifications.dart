import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'module_pages.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override Widget build(BuildContext context) => const GenericModulePage(title: 'Notifications', role: UserRole.student);
}
