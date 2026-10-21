import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/assignment_submission_repository.dart';

/// Assignment details screen for the SGU Student Campus app.
///
/// It is intentionally self-contained so it can be used with the existing
/// project without requiring a new package. If an existing AssignmentItem is
/// passed through [assignment], common fields are read when available.
class AssignmentDetailsPage extends StatefulWidget {
  final Object? assignment;
  final String title;
  final String courseName;
  final String marks;
  final String dueDate;
  final String instructions;
  final String status;

  const AssignmentDetailsPage({
    super.key,
    this.assignment,
    this.title = 'Deep Learning Assignment',
    this.courseName = 'Deep Learning',
    this.marks = '20 marks',
    this.dueDate = '25 Sep • 11:59 PM',
    this.instructions =
    'Complete the assigned work and upload your final submission before the deadline. Include all required files and references.',
    this.status = 'Pending',
  });

  @override
  State<AssignmentDetailsPage> createState() => _AssignmentDetailsPageState();
}

class _AssignmentDetailsPageState extends State<AssignmentDetailsPage> {
  bool _uploaded = false;
  bool _submitted = false;
  String _fileName = '';
  Uint8List? _fileBytes;
  String _contentType = 'application/octet-stream';
  bool _submitting = false;

  String _value(String name, String fallback) {
    final value = widget.assignment;
    if (value == null) return fallback;

    try {
      final dynamic item = value;
      final dynamic result = switch (name) {
        'title' => item.title,
        'courseName' => item.courseName,
        'marks' => item.marks,
        'dueDate' => item.dueDate,
        'instructions' => item.instructions,
        'status' => item.status,
        _ => null,
      };
      if (result != null && result.toString().trim().isNotEmpty) {
        return result.toString();
      }
    } catch (_) {
      // The existing project may use a different assignment model.
      // The safe demo values below are then used.
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final title = _value('title', widget.title);
    final course = _value('courseName', widget.courseName);
    final marks = _value('marks', widget.marks);
    final due = _value('dueDate', widget.dueDate);
    final instructions = _value('instructions', widget.instructions);
    final status = _submitted ? 'Submitted' : _value('status', widget.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF17243D),
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Assignment Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final maxWidth = wide ? 1180.0 : 760.0;

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    wide ? 28 : 16,
                    22,
                    wide ? 28 : 16,
                    40,
                  ),
                  child: wide
                      ? _wideLayout(
                    title: title,
                    course: course,
                    marks: marks,
                    due: due,
                    status: status,
                    instructions: instructions,
                  )
                      : _narrowLayout(
                    title: title,
                    course: course,
                    marks: marks,
                    due: due,
                    status: status,
                    instructions: instructions,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _wideLayout({
    required String title,
    required String course,
    required String marks,
    required String due,
    required String status,
    required String instructions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeader(title, course, marks, status),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: _instructionsCard(instructions, due),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: _submissionCard(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _narrowLayout({
    required String title,
    required String course,
    required String marks,
    required String due,
    required String status,
    required String instructions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeader(title, course, marks, status),
        const SizedBox(height: 16),
        _instructionsCard(instructions, due),
        const SizedBox(height: 16),
        _submissionCard(),
      ],
    );
  }

  Widget _pageHeader(
      String title,
      String course,
      String marks,
      String status,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF17243D),
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$course • $marks',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6F7D91),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _statusChip(status),
      ],
    );
  }

  Widget _statusChip(String status) {
    final submitted = status.toLowerCase() == 'submitted';
    final color = submitted ? const Color(0xFF2E7D32) : const Color(0xFFF57C00);
    final background = submitted
        ? const Color(0xFFEAF6EC)
        : const Color(0xFFFFF2E5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _instructionsCard(String instructions, String due) {
    return _surface(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instructions',
              style: TextStyle(
                color: Color(0xFF2B2928),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              instructions,
              style: const TextStyle(
                color: Color(0xFF3F3B39),
                fontSize: 15,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF2D5D0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    size: 20,
                    color: Color(0xFFC62828),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Due:',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC62828),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      due,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC62828),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _submissionCard() {
    return _surface(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submission',
              style: TextStyle(
                color: Color(0xFF2B2928),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            if (_uploaded) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8FC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD9E4EF)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insert_drive_file_outlined,
                      color: Color(0xFF1976D2),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        _fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove file',
                      onPressed: () {
                        setState(() {
                          _uploaded = false;
                          _fileName = '';
                          _fileBytes = null;
                          _submitted = false;
                        });
                      },
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _submitting ? null : _chooseFile,
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(_uploaded ? 'Change File' : 'Upload File'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _uploaded && !_submitted && !_submitting ? _submit : null,
                icon: const Icon(Icons.send_outlined),
                label: Text(_submitting ? 'Uploading to Firebase…' : (_submitted ? 'Submitted' : 'Submit Assignment')),
              ),
            ),
            if (!_uploaded) ...[
              const SizedBox(height: 10),
              const Text(
                'Upload a file before submitting.',
                style: TextStyle(
                  color: Color(0xFF7A8494),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _surface({required Widget child}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E5EA)),
        ),
        child: child,
      ),
    );
  }

  Future<void> _chooseFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'zip', 'txt', 'png', 'jpg', 'jpeg'],
        withData: true,
      );
      if (result == null || result.files.isEmpty || !mounted) return;
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read the selected file. Please select it again.')),
        );
        return;
      }
      if (bytes.length > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a file smaller than 10 MB.')),
        );
        return;
      }
      final ext = (file.extension ?? '').toLowerCase();
      final type = switch (ext) {
        'pdf' => 'application/pdf',
        'doc' => 'application/msword',
        'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'ppt' => 'application/vnd.ms-powerpoint',
        'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'zip' => 'application/zip',
        'txt' => 'text/plain',
        'png' => 'image/png',
        'jpg' || 'jpeg' => 'image/jpeg',
        _ => 'application/octet-stream',
      };
      setState(() {
        _uploaded = true;
        _fileName = file.name;
        _fileBytes = bytes;
        _contentType = type;
        _submitted = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected ${file.name}. It will upload to Firebase when submitted.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File selection failed: $error')));
    }
  }

  Future<void> _submit() async {
    final bytes = _fileBytes;
    if (bytes == null) return;
    setState(() => _submitting = true);
    try {
      await AssignmentSubmissionRepository().submit(
        assignmentTitle: _value('title', widget.title),
        courseName: _value('courseName', widget.courseName),
        fileName: _fileName,
        bytes: bytes,
        contentType: _contentType,
      );
      if (!mounted) return;
      setState(() => _submitted = true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Assignment file and submission details saved to Firebase.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not submit assignment: $error')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
