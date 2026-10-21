import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../services/profile_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// A small built-in square cropper. The user can zoom and reposition the
/// crop before the JPEG is uploaded. This avoids platform-specific cropper
/// plugins and works in Flutter Web as well as desktop/mobile builds.
class _ProfilePhotoCropDialog extends StatefulWidget {
  const _ProfilePhotoCropDialog({required this.imageBytes});
  final Uint8List imageBytes;

  @override
  State<_ProfilePhotoCropDialog> createState() => _ProfilePhotoCropDialogState();
}

class _ProfilePhotoCropDialogState extends State<_ProfilePhotoCropDialog> {
  late final img.Image _source;
  double _zoom = 1.0;
  double _horizontal = 0.5;
  double _vertical = 0.5;

  @override
  void initState() {
    super.initState();
    final decoded = img.decodeImage(widget.imageBytes);
    if (decoded == null) {
      throw const FormatException('This image format could not be opened. Try JPG or PNG.');
    }
    _source = img.bakeOrientation(decoded);
  }

  Uint8List _cropBytes() {
    final side = (_source.width < _source.height ? _source.width : _source.height) / _zoom;
    final maxLeft = _source.width - side;
    final maxTop = _source.height - side;
    final left = (maxLeft * _horizontal).round().clamp(0, _source.width - side.ceil()).toInt();
    final top = (maxTop * _vertical).round().clamp(0, _source.height - side.ceil()).toInt();
    final crop = img.copyCrop(
      _source,
      x: left,
      y: top,
      width: side.round().clamp(1, _source.width).toInt(),
      height: side.round().clamp(1, _source.height).toInt(),
    );
    return Uint8List.fromList(img.encodeJpg(crop, quality: 90));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Crop profile picture'),
    content: SizedBox(
      width: 360,
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Move the crop with the position sliders and zoom in for a closer portrait.'),
        const SizedBox(height: 18),
        Container(
          width: 260,
          height: 260,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF4F5F7)),
          clipBehavior: Clip.antiAlias,
          child: Image.memory(_cropBytes(), fit: BoxFit.cover, gaplessPlayback: true),
        ),
        const SizedBox(height: 14),
        Row(children: [const SizedBox(width: 72, child: Text('Zoom')), Expanded(child: Slider(value: _zoom, min: 1, max: 3, divisions: 20, label: '${_zoom.toStringAsFixed(1)}×', onChanged: (v) => setState(() => _zoom = v)))]),
        Row(children: [const SizedBox(width: 72, child: Text('Left / right')), Expanded(child: Slider(value: _horizontal, min: 0, max: 1, onChanged: (v) => setState(() => _horizontal = v)))]),
        Row(children: [const SizedBox(width: 72, child: Text('Up / down')), Expanded(child: Slider(value: _vertical, min: 0, max: 1, onChanged: (v) => setState(() => _vertical = v)))]),
      ])),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton.icon(onPressed: () => Navigator.pop(context, _cropBytes()), icon: const Icon(Icons.check), label: const Text('Use this photo')),
    ],
  );
}

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});
  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final _repository = ProfileRepository();
  bool _uploadingPhoto = false;

  Future<void> _pickProfilePhoto(Map<String, dynamic> current) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (picked == null || picked.files.isEmpty || !mounted) return;
      final bytes = picked.files.single.bytes;
      if (bytes == null || bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read that image. Please choose another picture.')),
        );
        return;
      }
      if (bytes.length > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please choose an image smaller than 10 MB.')),
        );
        return;
      }

      final croppedBytes = await showDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ProfilePhotoCropDialog(imageBytes: bytes),
      );
      if (croppedBytes == null || !mounted) return;

      setState(() => _uploadingPhoto = true);
      // Always upload the cropped image as JPEG, so the storage path and MIME
      // type stay consistent on Chrome, Windows, Android and iOS.
      final photoName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref('profilePhotos/${user.uid}/$photoName');
      await ref.putData(
        croppedBytes,
        SettableMetadata(contentType: 'image/jpeg', cacheControl: 'no-cache'),
      );
      final url = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photoUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await user.updatePhotoURL(url);
      await user.reload();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture cropped and updated successfully.')),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        final message = e.code == 'unauthorized'
            ? 'Firebase Storage denied this upload. Deploy storage.rules and check that this account is signed in.'
            : 'Could not update photo (${e.code}). Check Firebase Storage and Firestore rules.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _showStudentCard({required String name, required String id, required String programme, required String email, required String semester, required String photoUrl}) {
    showDialog<void>(context: context, builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [const Icon(Icons.verified_user_outlined, color: AppTheme.red), const SizedBox(width: 8), const Expanded(child: Text('SGU STUDENT ID CARD', style: TextStyle(fontSize: 12, letterSpacing: 1.1, fontWeight: FontWeight.w900, color: AppTheme.red))), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))]),
        const SizedBox(height: 12),
        Container(width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.darkRed, AppTheme.red]), borderRadius: BorderRadius.circular(22)), child: Column(children: [
          CircleAvatar(radius: 46, backgroundColor: Colors.white, backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null, child: photoUrl.isEmpty ? const Icon(Icons.person, size: 48, color: AppTheme.red) : null),
          const SizedBox(height: 14), Text(name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6), Text(id.isEmpty ? 'Student ID not added' : 'Student ID  $id', style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 6), Text([programme, semester.isEmpty ? '' : 'Semester $semester'].where((x) => x.isNotEmpty).join(' • '), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 14), const Divider(color: Colors.white38), Text(email, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ])),
        const SizedBox(height: 14), const Text('For campus identification only. Keep your account details up to date.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 12)),
        const SizedBox(height: 8), Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))),
      ]))),
    ));
  }
  late final Stream<Map<String, dynamic>?> _profileStream = _repository.watchProfile();

  Future<void> _editProfile(Map<String, dynamic> current) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: (current['name'] ?? FirebaseAuth.instance.currentUser?.displayName ?? '').toString());
    final studentId = TextEditingController(text: (current['studentId'] ?? '').toString());
    final programme = TextEditingController(text: (current['programme'] ?? '').toString());
    final phone = TextEditingController(text: (current['phone'] ?? '').toString());
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit student profile'),
        content: SizedBox(width: 500, child: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Full name *'), validator: (v) => (v?.trim().length ?? 0) < 3 ? 'Enter your full name.' : null),
          const SizedBox(height: 12),
          TextFormField(controller: studentId, decoration: const InputDecoration(labelText: 'Student ID *'), validator: (v) => (v?.trim().length ?? 0) < 4 ? 'Enter a valid student ID.' : null),
          const SizedBox(height: 12),
          TextFormField(controller: programme, decoration: const InputDecoration(labelText: 'Programme *'), validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Enter your programme.' : null),
          const SizedBox(height: 12),
          TextFormField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number'), validator: (v) { final value = v?.trim() ?? ''; return value.isNotEmpty && !RegExp(r'^\+?[0-9 ()-]{7,20}$').hasMatch(value) ? 'Enter a valid phone number.' : null; }),
          const SizedBox(height: 8),
          const Text('Changes are saved to your signed-in Firebase user profile.', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
        ])))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () { if (formKey.currentState?.validate() ?? false) Navigator.pop(dialogContext, true); }, child: const Text('Save profile')),
        ],
      ),
    );
    if (accepted == true && mounted) {
      try {
        await _repository.saveProfile(name: name.text, studentId: studentId.text, programme: programme.text, phone: phone.text);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved. Live profile data will refresh automatically.')));
      } on FirebaseException catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save profile (${e.code}). Deploy the latest firestore.rules in Firebase Console.')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save profile: $e')));
      }
    }
    name.dispose(); studentId.dispose(); programme.dispose(); phone.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _profileStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
        }
        final data = snapshot.data ?? const <String, dynamic>{};
        final name = (data['name'] ?? user?.displayName ?? 'Complete your profile').toString();
        final id = (data['studentId'] ?? 'Not added').toString();
        final programme = (data['programme'] ?? 'Not added').toString();
        final email = (user?.email ?? data['email'] ?? 'No email').toString();
        final phone = (data['phone'] ?? 'Not added').toString();
        final semester = (data['semester'] ?? 'Not set').toString();
        final initials = name.trim().isEmpty ? 'SGU' : name.trim().split(RegExp(r'\s+')).take(2).map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();
        return PageContainer(
          title: 'My Profile',
          subtitle: 'Your personal and academic details, synced live with Firebase.',
          actions: [FilledButton.icon(onPressed: user == null ? null : () => _editProfile(data), icon: const Icon(Icons.edit_outlined), label: const Text('Edit profile'))],
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (snapshot.hasError)
              Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.red.withValues(alpha: .08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.red.withValues(alpha: .25))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Profile could not be loaded from Firebase', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.darkRed)),
                const SizedBox(height: 6),
                const Text('Your signed-in Firebase account is available, but Firestore denied access to the users/{uid} profile document. Deploy the project firestore.rules to SGUERP, then reload this page. Do not make the database public. You can still open Edit profile, but saving will work only after the correct rules are deployed.'),
                const SizedBox(height: 8),
                SelectableText(snapshot.error.toString(), style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
              ])),
            Card(child: Padding(padding: const EdgeInsets.all(22), child: LayoutBuilder(builder: (context, box) {
              final photoUrl = (data['photoUrl'] ?? user?.photoURL ?? '').toString();
              final identity = Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Stack(children: [CircleAvatar(radius: 42, backgroundColor: const Color(0xFFFFE0DD), backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null, child: photoUrl.isEmpty ? Text(initials, style: const TextStyle(color: AppTheme.darkRed, fontWeight: FontWeight.w900, fontSize: 18)) : null), Positioned(right: 0, bottom: 0, child: Material(color: AppTheme.red, shape: const CircleBorder(), child: InkWell(customBorder: const CircleBorder(), onTap: _uploadingPhoto ? null : () => _pickProfilePhoto(data), child: Padding(padding: const EdgeInsets.all(7), child: _uploadingPhoto ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16))))) ]),
                const SizedBox(width: 18), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: AppTheme.navy)), const SizedBox(height: 5), Text(email, style: const TextStyle(color: AppTheme.muted)), const SizedBox(height: 8), const Wrap(spacing: 8, runSpacing: 8, children: [Chip(avatar: Icon(Icons.verified_user_outlined, size: 16), label: Text('Firebase account')), Chip(avatar: Icon(Icons.sync, size: 16), label: Text('Live profile'))])]))
              ]);
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [identity, const SizedBox(height: 18), Wrap(spacing: 10, runSpacing: 10, children: [OutlinedButton.icon(onPressed: () => _pickProfilePhoto(data), icon: const Icon(Icons.add_a_photo_outlined), label: const Text('Change picture')), FilledButton.icon(onPressed: () => _showStudentCard(name: name, id: id == 'Not added' ? '' : id, programme: programme == 'Not added' ? '' : programme, email: email, semester: semester == 'Not set' ? '' : semester, photoUrl: photoUrl), icon: const Icon(Icons.badge_outlined), label: const Text('View student ID card'))])]);
            }))),
            const SizedBox(height: 16),
            const Text('Personal and academic information', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.navy)),
            const SizedBox(height: 10),
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth >= 850 ? 2 : 1;
              final items = <(IconData, String, String)>[
                (Icons.badge_outlined, 'Student ID', id),
                (Icons.school_outlined, 'Programme', programme),
                (Icons.email_outlined, 'University email', email),
                (Icons.phone_outlined, 'Phone number', phone),
                (Icons.calendar_month_outlined, 'Semester', semester),
                (Icons.fingerprint_outlined, 'Firebase UID', user?.uid ?? 'Not signed in'),
              ];
              return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 100), itemBuilder: (context, index) {
                final item = items[index];
                return Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: AppTheme.info.withValues(alpha: .09), borderRadius: BorderRadius.circular(12)), child: Icon(item.$1, color: AppTheme.info)), const SizedBox(width: 12), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.$2, style: const TextStyle(color: AppTheme.muted, fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 5), Text(item.$3, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w700))]))])));
              });
            }),
          ]),
        );
      },
    );
  }
}
