import 'package:flutter/material.dart';
import '../shared/module_pages.dart';
import '../../models/models.dart';

class StudentTranscriptPage extends StatelessWidget {
  const StudentTranscriptPage({super.key});
  @override
  Widget build(BuildContext context) => const GenericModulePage(title: 'Transcript', role: UserRole.student);
}
