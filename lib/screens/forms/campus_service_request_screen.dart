import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/campus_request_repository.dart';
import '../../theme/app_theme.dart';
import '../routes/route_widgets.dart';

class CampusServiceRequestScreen extends StatefulWidget {
  const CampusServiceRequestScreen({super.key});

  @override
  State<CampusServiceRequestScreen> createState() =>
      _CampusServiceRequestScreenState();
}

class _CampusServiceRequestScreenState
    extends State<CampusServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  // The form key coordinates field validation, saving, and resetting.
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _detailsController = TextEditingController();
  String _savedName = '';
  String _savedId = '';
  String _savedEmail = '';
  String _savedPhone = '';
  String _savedSubject = '';
  String _savedDescription = '';

  String? _service;
  String _urgency = 'Normal';
  String _contact = 'Email';
  DateTime? _preferredDate;
  bool _declaration = false;
  int _detailsLength = 0;
  bool _isSubmitting = false;
  String? _lastRequestId;
  final _repository = CampusRequestRepository();

  final List<String> _serviceOptions = const [
    'Accommodation',
    'IT Helpdesk',
    'Library Services',
    'Student Counselling',
    'Career Services',
  ];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _emailController.text = user?.email ?? '';
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _loadStudentDetails(user.uid);
    }
    _detailsController.addListener(() {
      setState(() => _detailsLength = _detailsController.text.length);
    });
  }

  Future<void> _loadStudentDetails(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!mounted || !doc.exists) return;
      final data = doc.data() ?? <String, dynamic>{};
      setState(() {
        if ((data['name'] ?? '').toString().trim().isNotEmpty) _nameController.text = (data['name']).toString();
        if (_idController.text.trim().isEmpty) _idController.text = (data['studentId'] ?? '').toString();
        if (_emailController.text.trim().isEmpty) _emailController.text = (data['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '').toString();
        if (_phoneController.text.trim().isEmpty) _phoneController.text = (data['phone'] ?? '').toString();
      });
    } on FirebaseException {
      // The form stays usable; the student can enter details manually if the profile is not readable yet.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RoutePageFrame(
      title: 'Campus Service Request',
      subtitle:
          'Submit a campus support request using the validated Flutter Form.',
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 900;
            final form = AbsorbPointer(
              absorbing: _isSubmitting || _lastRequestId != null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionCard(
                    title: 'Student Details',
                    icon: Icons.person_outline,
                    child: LayoutBuilder(builder: (context, fieldBox) {
                      final twoColumns = fieldBox.maxWidth >= 650;
                      final fieldWidth = twoColumns ? (fieldBox.maxWidth - 12) / 2 : fieldBox.maxWidth;
                      return Wrap(spacing: 12, runSpacing: 12, children: [
                        SizedBox(width: fieldWidth, child: _textField(
                          controller: _nameController,
                          label: 'Student Name',
                          hint: 'Enter your full name',
                          icon: Icons.badge_outlined,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return 'Please enter your full name.';
                            if (text.split(RegExp(r'\s+')).length < 2) return 'Please enter at least two words.';
                            return null;
                          },
                          onSaved: (value) => _savedName = value?.trim() ?? '',
                          textInputAction: TextInputAction.next,
                        )),
                        SizedBox(width: fieldWidth, child: _textField(
                          controller: _idController,
                          label: 'Student ID',
                          hint: 'Example: I26043300',
                          icon: Icons.badge_outlined,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return 'Please enter your student ID.';
                            if (text.length < 6) return 'Student ID is too short.';
                            return null;
                          },
                          onSaved: (value) => _savedId = value?.trim() ?? '',
                          textInputAction: TextInputAction.next,
                        )),
                        SizedBox(width: fieldWidth, child: _textField(
                          controller: _emailController,
                          label: 'Campus Email',
                          hint: 'name@sgu.edu.in',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return 'Please enter your campus email.';
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) return 'Please enter a valid email address.';
                            return null;
                          },
                          onSaved: (value) => _savedEmail = value?.trim() ?? '',
                          textInputAction: TextInputAction.next,
                        )),
                        SizedBox(width: fieldWidth, child: _textField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: 'Optional: +91...',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (_contact == 'Phone' && text.isEmpty) return 'Enter a phone number for phone contact.';
                            if (text.isEmpty) return null;
                            if (!RegExp(r'^\+?[0-9 ]{8,15}$').hasMatch(text)) return 'Enter a valid phone number.';
                            return null;
                          },
                          onSaved: (value) => _savedPhone = value?.trim() ?? '',
                          textInputAction: TextInputAction.next,
                        )),
                      ]);
                    }),
                  ),
                  const SizedBox(height: 14),
                  _sectionCard(
                    title: 'Request Details',
                    icon: Icons.support_agent_outlined,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _service,
                          decoration: const InputDecoration(
                            labelText: 'Service Category',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: _serviceOptions
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _service = value),
                          validator: (value) => value == null
                              ? 'Please select a service category.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _textField(
                          controller: _subjectController,
                          label: 'Request Subject',
                          hint: 'Briefly describe the issue',
                          icon: Icons.subject_outlined,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Please enter a request subject.';
                            }
                            if (text.length < 5) {
                              return 'Please enter a meaningful subject.';
                            }
                            return null;
                          },
                          onSaved: (value) =>
                              _savedSubject = value?.trim() ?? '',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _detailsController,
                          maxLines: 5,
                          maxLength: 300,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          decoration: const InputDecoration(
                            labelText: 'Request Details',
                            hintText: 'Explain what you need help with...',
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(bottom: 74),
                              child: Icon(Icons.notes_outlined),
                            ),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Please describe your request.';
                            }
                            if (text.length < 20) {
                              return 'Please enter at least 20 characters.';
                            }
                            if (text.length > 300) {
                              return 'Please keep the request below 300 characters.';
                            }
                            return null;
                          },
                          onSaved: (value) =>
                              _savedDescription = value?.trim() ?? '',
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$_detailsLength / 300',
                            style: TextStyle(
                              fontSize: 11,
                              color: _detailsLength > 300
                                  ? AppTheme.red
                                  : AppTheme.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _choiceSection(
                          title: 'Urgency',
                          options: const ['Low', 'Normal', 'High'],
                          selected: _urgency,
                          onSelected: (value) =>
                              setState(() => _urgency = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _sectionCard(
                    title: 'Preferences',
                    icon: Icons.tune_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Preferred Contact',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RadioGroup<String>(
                          groupValue: _contact,
                          onChanged: (value) =>
                              setState(() => _contact = value ?? 'Email'),
                          child: Wrap(
                            spacing: 10,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Radio<String>(value: 'Email'),
                                  const Text('Email'),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Radio<String>(value: 'Phone'),
                                  const Text('Phone'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Preferred Date',
                            prefixIcon: Icon(Icons.calendar_month_outlined),
                          ),
                          child: InkWell(
                            onTap: _pickDate,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                _preferredDate == null
                                    ? 'Select a date'
                                    : _formatDate(_preferredDate!),
                                style: TextStyle(
                                  color: _preferredDate == null
                                      ? AppTheme.muted
                                      : AppTheme.navy,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_preferredDate == null)
                          const Padding(
                            padding: EdgeInsets.only(left: 12, top: 6),
                            child: Text(
                              'Please choose a preferred response date.',
                              style: TextStyle(
                                color: AppTheme.red,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _sectionCard(
                    title: 'Confirmation',
                    icon: Icons.verified_user_outlined,
                    child: Column(
                      children: [
                        CheckboxListTile(
                          value: _declaration,
                          onChanged: (value) =>
                              setState(() => _declaration = value ?? false),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text(
                            'I confirm that the information provided is correct.',
                          ),
                          subtitle: const Text(
                            'The request will be submitted using the details above.',
                          ),
                        ),
                        if (!_declaration)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Please confirm before submitting.',
                              style: TextStyle(
                                color: AppTheme.red,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            final pageContent = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                form,
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed:
                          _isSubmitting ||
                              _lastRequestId != null ||
                              Firebase.apps.isEmpty
                          ? null
                          : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_outlined),
                      label: Text(
                        _isSubmitting
                            ? 'SAVING…'
                            : _lastRequestId != null
                            ? 'SUBMITTED'
                            : 'SUBMIT REQUEST',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('RESET'),
                    ),
                    if (_lastRequestId != null && !_isSubmitting)
                      TextButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.requestSummary,
                          arguments: _lastRequestId,
                        ),
                        icon: const Icon(Icons.verified_outlined),
                        label: const Text('VERIFY SAVED REQUEST'),
                      ),
                  ],
                ),
              ],
            );

            if (!desktop) {
              return pageContent;
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: pageContent),
                const SizedBox(width: 18),
                SizedBox(width: 285, child: _summaryCard()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.red.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: AppTheme.red, size: 19),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    void Function(String?)? onSaved,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _choiceSection({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            return ChoiceChip(
              label: Text(option),
              selected: option == selected,
              onSelected: (_) => onSelected(option),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _summaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Complete the required fields before submitting.',
              style: TextStyle(fontSize: 12, color: AppTheme.muted),
            ),
            const SizedBox(height: 18),
            _progressRow(
              'Student details',
              _nameController.text.isNotEmpty &&
                  _idController.text.isNotEmpty &&
                  _emailController.text.isNotEmpty,
            ),
            _progressRow('Service', _service != null),
            _progressRow('Description', _detailsLength >= 20),
            _progressRow('Date', _preferredDate != null),
            _progressRow('Confirmation', _declaration),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.info.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Tip: use Reset if you want to start a completely new request. All form and selection state will be cleared.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.muted,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressRow(String label, bool complete) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            complete ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: complete ? AppTheme.success : AppTheme.muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDate:
          _preferredDate != null &&
              !_preferredDate!.isBefore(DateTime(now.year, now.month, now.day))
          ? _preferredDate!
          : DateTime(now.year, now.month, now.day),
    );
    if (!mounted || picked == null) return;
    setState(() => _preferredDate = picked);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _submit() async {
    if (_isSubmitting || _lastRequestId != null) return;
    // Never save or submit until every field-level validator passes.
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the marked fields before submitting.'),
        ),
      );
      return;
    }
    if (_preferredDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a preferred date.')),
      );
      return;
    }
    if (!_declaration) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm the declaration before submitting.'),
        ),
      );
      return;
    }

    // Save callbacks snapshot validated values before the asynchronous write.
    _formKey.currentState?.save();
    final reference = _repository.newRequestReference();
    setState(() {
      _lastRequestId = reference.id;
      _isSubmitting = true;
    });
    try {
      await _repository.submit(
        reference: reference,
        studentName: _savedName,
        studentId: _savedId,
        email: _savedEmail,
        phone: _savedPhone,
        serviceCategory: _service!,
        subject: _savedSubject,
        description: _savedDescription,
        urgency: _urgency,
        preferredContact: _contact,
        preferredDate: _preferredDate!,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await Navigator.pushNamed(
        context,
        AppRoutes.requestSummary,
        arguments: reference.id,
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final definitelyRejected = {
        'permission-denied',
        'unauthenticated',
        'operation-not-allowed',
        'invalid-argument',
      }.contains(error.code);
      if (definitelyRejected) setState(() => _lastRequestId = null);
      final message = switch (error.code) {
        'permission-denied' => 'Access denied. Check that Anonymous Authentication is enabled and firestore.rules are published.',
        'operation-not-allowed' =>
          'Anonymous sign-in is disabled in this Firebase project.',
        'unauthenticated' =>
          'Sign-in failed. Check Firebase Authentication setup and retry.',
        _ =>
          definitelyRejected
              ? 'Firebase rejected this request (${error.code}). Check the project configuration and try again.'
              : 'The save result could not be confirmed. Keep reference ${reference.id} and verify it before submitting again.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 6)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'The save result could not be confirmed. Keep reference ${reference.id} and verify it before submitting again. ($error)',
          ),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  void _reset() {
    _formKey.currentState?.reset();
    // Reset both FormFields and state held outside FormFields.
    _nameController.clear();
    _idController.clear();
    final user = FirebaseAuth.instance.currentUser;
    _emailController.text = user?.email ?? '';
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _loadStudentDetails(user.uid);
    }
    _phoneController.clear();
    _subjectController.clear();
    _detailsController.clear();
    setState(() {
      _service = null;
      _urgency = 'Normal';
      _contact = 'Email';
      _preferredDate = null;
      _declaration = false;
      _detailsLength = 0;
      _lastRequestId = null;
      _isSubmitting = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('New request form is ready.')));
  }
}
