import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminAnnouncementsPage extends StatelessWidget {
  const AdminAnnouncementsPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Announcements', role: UserRole.admin);
}
