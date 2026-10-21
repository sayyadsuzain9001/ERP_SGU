import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentHallTicketPage extends StatelessWidget {
  const StudentHallTicketPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Hall Ticket', role: UserRole.student);
}
