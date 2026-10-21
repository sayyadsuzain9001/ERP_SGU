import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'module_pages.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});
  @override Widget build(BuildContext context) => const GenericModulePage(title: 'Messages', role: UserRole.student);
}
