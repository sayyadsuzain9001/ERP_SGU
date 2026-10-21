import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'module_pages.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});
  @override Widget build(BuildContext context) => const GenericModulePage(title: 'Requests', role: UserRole.student);
}
