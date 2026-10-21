import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class AdminFacilitiesPage extends StatelessWidget {
  const AdminFacilitiesPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Facilities', role: UserRole.admin);
}
