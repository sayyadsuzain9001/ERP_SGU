import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FirebaseSignInScreen extends StatefulWidget {
  const FirebaseSignInScreen({super.key});
  @override
  State<FirebaseSignInScreen> createState() => _FirebaseSignInScreenState();
}

class _FirebaseSignInScreenState extends State<FirebaseSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _studentId = TextEditingController();
  final _programme = TextEditingController();
  final _staffId = TextEditingController();
  final _department = TextEditingController();
  final _phone = TextEditingController();
  String _accountType = 'student';
  bool _register = false;
  bool _busy = false;
  bool _obscure = true;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _password.dispose(); _studentId.dispose();
    _programme.dispose(); _staffId.dispose(); _department.dispose(); _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _busy = true; _error = null; _notice = null; });
    try {
      final auth = FirebaseAuth.instance;
      if (_register) {
        final credential = await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(), password: _password.text,
        );
        final user = credential.user;
        if (user == null) throw StateError('Firebase did not return the new user.');
        await user.updateDisplayName(_name.text.trim());
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': _name.text.trim(),
          'email': user.email ?? _email.text.trim(),
          'accountType': _accountType,
          // A requested role is profile metadata, not an authorization claim.
          // Teacher access must be granted separately by a trusted administrator.
          'requestedRole': _accountType,
          'phone': _phone.text.trim(),
          if (_accountType == 'student') ...{
            'studentId': _studentId.text.trim(),
            'programme': _programme.text.trim(),
          },
          if (_accountType == 'teacher') ...{
            'staffId': _staffId.text.trim(),
            'department': _department.text.trim(),
            'roleApprovalStatus': 'pending',
          },
          'profileComplete': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await auth.signInWithEmailAndPassword(email: _email.text.trim(), password: _password.text);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = switch (e.code) {
        'invalid-email' => 'Enter a valid email address.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' => 'Email or password is incorrect.',
        'email-already-in-use' => 'An account already exists for this email.',
        'weak-password' => 'Use a stronger password with at least 6 characters.',
        'network-request-failed' => 'Network error. Check your internet connection.',
        'operation-not-allowed' => 'Enable Email/Password in Firebase Authentication settings.',
        _ => e.message ?? 'Authentication failed. Please try again.',
      });
    } on FirebaseException catch (e) {
      // The account may have been created before a Firestore rules failure.
      if (mounted) setState(() => _error = 'Account authentication succeeded, but the profile could not be saved (${e.code}). Deploy firestore.rules, then sign in and complete your profile.');
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not complete the request. Check Firebase configuration and connection.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() { _error = 'Enter your email first, then choose Forgot password.'; _notice = null; });
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) setState(() { _notice = 'Password reset email sent. Check your inbox.'; _error = null; });
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'Could not send password reset email.');
    }
  }

  String? _required(String? value, String label, {int min = 2}) =>
      (value?.trim().length ?? 0) < min ? 'Enter $label (at least $min characters).' : null;

  Widget _field(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboard = TextInputType.text, String? Function(String?)? validator}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller, keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: validator,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isTeacher = _accountType == 'teacher';
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Container(
                      height: 76, width: 76, alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppTheme.red.withValues(alpha: .09), shape: BoxShape.circle),
                      child: const Icon(Icons.school_rounded, color: AppTheme.red, size: 42),
                    ),
                    const SizedBox(height: 14),
                    const Text('SGU Student Campus', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.navy)),
                    const SizedBox(height: 6),
                    Text(_register ? 'Create your university account' : 'Welcome back. Sign in to continue.',
                      textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted)),
                    const SizedBox(height: 24),
                    if (_register) ...[
                      _field(_name, 'Full name *', Icons.person_outline, validator: (v) => _required(v, 'your full name', min: 3)),
                      DropdownButtonFormField<String>(
                        initialValue: _accountType,
                        decoration: const InputDecoration(labelText: 'Account type *', prefixIcon: Icon(Icons.badge_outlined)),
                        items: const [
                          DropdownMenuItem(value: 'student', child: Text('Student')),
                          DropdownMenuItem(value: 'teacher', child: Text('Teacher / Faculty')),
                        ],
                        onChanged: _busy ? null : (value) => setState(() => _accountType = value ?? 'student'),
                      ),
                      const SizedBox(height: 12),
                      if (!isTeacher) ...[
                        _field(_studentId, 'Student ID *', Icons.numbers_outlined, validator: (v) => _required(v, 'your student ID', min: 4)),
                        _field(_programme, 'Programme / course *', Icons.school_outlined, validator: (v) => _required(v, 'your programme', min: 2)),
                      ] else ...[
                        _field(_staffId, 'Staff ID *', Icons.badge_outlined, validator: (v) => _required(v, 'your staff ID', min: 3)),
                        _field(_department, 'Department *', Icons.account_tree_outlined, validator: (v) => _required(v, 'your department', min: 2)),
                      ],
                      _field(_phone, 'Phone number *', Icons.phone_outlined, keyboard: TextInputType.phone,
                        validator: (v) => (v?.trim().length ?? 0) < 7 ? 'Enter a valid phone number.' : null),
                      const SizedBox(height: 2),
                    ],
                    _field(_email, 'University email *', Icons.email_outlined, keyboard: TextInputType.emailAddress,
                      validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '') ? null : 'Enter a valid email address.'),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextFormField(
                        controller: _password, obscureText: _obscure,
                        decoration: InputDecoration(labelText: 'Password *', prefixIcon: const Icon(Icons.lock_outline),
                          helperText: _register ? 'Use at least 8 characters.' : null,
                          suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
                        validator: (v) => (v?.length ?? 0) < (_register ? 8 : 6) ? 'Password is too short.' : null,
                      ),
                    ),
                    if (!_register) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _busy ? null : _resetPassword, child: const Text('Forgot password?'))),
                    if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: const TextStyle(color: AppTheme.red))),
                    if (_notice != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_notice!, style: const TextStyle(color: AppTheme.success))),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _busy ? null : _submit,
                      icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(_register ? Icons.person_add_alt_1 : Icons.login),
                      label: Text(_busy ? 'Please wait…' : _register ? 'Create account' : 'Sign in'),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: _busy ? null : () => setState(() { _register = !_register; _error = null; _notice = null; }),
                      child: Text(_register ? 'Already have an account? Sign in' : 'New to SGU Student Campus? Create account')),
                    if (_register && isTeacher)
                      const Text('Teacher accounts require administrator approval before teacher tools are enabled.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                    const SizedBox(height: 8),
                    const Text('Your account and profile are stored using Firebase Authentication and Cloud Firestore.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
