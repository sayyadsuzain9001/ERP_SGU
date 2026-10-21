import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminHelpSupportPage extends StatelessWidget {
  const AdminHelpSupportPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Help & Support', role: UserRole.admin);
}
