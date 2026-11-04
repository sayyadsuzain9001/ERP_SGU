import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Student home page designed around the supplied clean university portal references.
/// Navigation actions always use the existing AppShell routes.
class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key, this.onNavigate});

  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 1120;
    final columns = width >= 1250 ? 4 : (width >= 760 ? 2 : 1);
    return PageContainer(
      title: 'Welcome to SGU Student Campus',
      subtitle: 'Your academic life, campus services and student opportunities in one place.',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _hero(context, wide),
        const SizedBox(height: 22),
        _overview(),
        const SizedBox(height: 16),
        _LiveNextClassReminder(onNavigate: onNavigate),
        const SizedBox(height: 34),
        _sectionIntro('STUDENT SPACE', 'Everything you need, around you.',
            'Open your schedule, campus services, events and student tools from one dashboard.'),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: width < 600 ? 3.1 : (width < 900 ? 1.75 : 1.65),
          children: [
            _feature('Timetable', 'Your classes and planner', Icons.calendar_month_outlined, 'Timetable'),
            _feature('Campus Services', 'Get help from university services', Icons.support_agent_outlined, 'Campus Services'),
            _feature('Announcements', 'Read campus news and bookmark updates', Icons.campaign_outlined, 'Announcements'),
            _feature('Facility Booking', 'Reserve campus spaces for your activities', Icons.event_available_outlined, 'Facility Booking'),
            _feature('Events', 'Workshops, clubs and opportunities', Icons.event_outlined, 'Events'),
            _feature('Explore Campus', 'Find university spaces', Icons.map_outlined, 'Campus'),
          ],
        ),
        const SizedBox(height: 38),
        _sectionIntro('STUDENT SUPPORT', 'Help when you need it.',
            'Quick access to campus support without searching through departments.'),
        const SizedBox(height: 16),
        _supportPanel(context, wide),
        const SizedBox(height: 38),
        _sectionIntro('UPCOMING', 'What’s happening next?', 'Discover student events and opportunities.'),
        const SizedBox(height: 16),
        const _LiveUpcomingEvents(),
        const SizedBox(height: 38),
        _sectionIntro('CAMPUS LIFE', 'Designed for more than classes.',
            'Study, collaborate, research and explore university life.'),
        const SizedBox(height: 16),
        _campusLife(wide),
      ]),
    );
  }

  Widget _hero(BuildContext context, bool wide) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: SizedBox(
      height: wide ? 390 : 320,
      width: double.infinity,
      child: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/images/sgu_campus.png', fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: AppTheme.darkRed)),
        DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
            colors: [Colors.white.withValues(alpha: .98), Colors.white.withValues(alpha: .88), Colors.white.withValues(alpha: .08)],
            stops: const [0, .48, 1]),
        )),
        Padding(padding: EdgeInsets.all(wide ? 30 : 20), child: Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 510), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.red.withValues(alpha: .08), borderRadius: BorderRadius.circular(30)),
                child: const Text('SANJAY GHODAWAT UNIVERSITY', style: TextStyle(color: AppTheme.darkRed, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .7))),
              const SizedBox(height: 14),
              Text('Learn. Connect.\nMake Your Mark.\nAt SGU.', style: TextStyle(color: AppTheme.ink, fontSize: wide ? 39 : 29, height: 1.0, fontWeight: FontWeight.w800, letterSpacing: -1.2)),
              const SizedBox(height: 10),
              const Text('Your SGU space for classes, campus services, student events and the next step in your journey.', style: TextStyle(color: AppTheme.muted, fontSize: 14, height: 1.5)),
              const SizedBox(height: 14),
              FilledButton.icon(onPressed: () => onNavigate?.call('Campus'), icon: const Icon(Icons.arrow_forward_rounded, size: 18), label: const Text('Explore Campus')),
            ],
          )),
        )),
      ]),
    ),
  );

  Widget _overview() => const _LiveAcademicOverview();

  Widget _sectionIntro(String eyebrow, String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(eyebrow, style: const TextStyle(color: AppTheme.red, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
    const SizedBox(height: 7), Text(title, style: const TextStyle(color: AppTheme.ink, fontSize: 27, fontWeight: FontWeight.w500, letterSpacing: -.7)),
    const SizedBox(height: 5), Text(subtitle, style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
  ]);

  Widget _feature(String title, String subtitle, IconData icon, String route) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(onTap: () => onNavigate?.call(route), borderRadius: BorderRadius.circular(20),
      child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.paleRed, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppTheme.red, size: 22)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.ink)), const SizedBox(height: 4), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 11, height: 1.4))]),
        ])),
    ),
  );

  Widget _supportPanel(BuildContext context, bool wide) => Container(
    width: double.infinity, padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(24)),
    child: wide ? Row(children: [
      Expanded(child: _supportTile(Icons.bolt_rounded, 'Quick Help', 'Find the right service quickly.', 'Service Request Form')),
      const SizedBox(width: 16), Expanded(child: _supportTile(Icons.warning_amber_rounded, 'Common Issues', 'Wi-Fi, ID cards, dormitory and documents.', 'Campus Services')),
      const SizedBox(width: 16), Expanded(child: _supportTile(Icons.receipt_long_outlined, 'Request Status', 'Review the status of your submitted requests.', 'Requests')),
    ]) : Column(children: [
      _supportTile(Icons.bolt_rounded, 'Quick Help', 'Find the right service quickly.', 'Service Request Form'), const SizedBox(height: 10),
      _supportTile(Icons.warning_amber_rounded, 'Common Issues', 'Wi-Fi, ID cards, dormitory and documents.', 'Campus Services'), const SizedBox(height: 10),
      _supportTile(Icons.receipt_long_outlined, 'Request Status', 'Review the status of your submitted requests.', 'Requests'),
    ]),
  );

  Widget _supportTile(IconData icon, String title, String subtitle, String route) => Material(
    color: AppTheme.bg,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: () => onNavigate?.call(route),
      borderRadius: BorderRadius.circular(16),
      child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: AppTheme.paleRed, borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: AppTheme.red)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppTheme.muted, fontSize: 11, height: 1.4)),
        ])),
        const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.muted),
      ])),
    ),
  );

  Widget _campusLife(bool wide) => wide ? Row(children: [
    Expanded(flex: 6, child: _campusImage('Academic Spaces', 'Spaces for learning and collaboration.', 230, 'https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=1400&q=85')),
    const SizedBox(width: 14), Expanded(flex: 4, child: Column(children: [
      _campusImage('Technology Labs', 'Build. Test. Innovate.', 108, 'https://images.unsplash.com/photo-1581092921461-eab62e97a780?auto=format&fit=crop&w=900&q=85'), const SizedBox(height: 14),
      _campusImage('Library', 'Read. Research. Focus.', 108, 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=900&q=85'),
    ])),
  ]) : Column(children: [
    _campusImage('Academic Spaces', 'Spaces for learning and collaboration.', 180, 'https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=1400&q=85'), const SizedBox(height: 12),
    _campusImage('Technology Labs', 'Build. Test. Innovate.', 130, 'https://images.unsplash.com/photo-1581092921461-eab62e97a780?auto=format&fit=crop&w=900&q=85'), const SizedBox(height: 12),
    _campusImage('Library', 'Read. Research. Focus.', 130, 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=900&q=85'),
  ]);

  Widget _campusImage(String title, String subtitle, double height, String imageUrl) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: SizedBox(height: height, width: double.infinity, child: Stack(fit: StackFit.expand, children: [
      Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, error, stack) => Container(color: AppTheme.navy)),
      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC151515)]))),
      Padding(padding: const EdgeInsets.all(18), child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ])),
    ])),
  );
}

class ExpandedIfNeeded extends StatelessWidget {
  const ExpandedIfNeeded({super.key, required this.expand, required this.child});
  final bool expand;
  final Widget child;
  @override
  Widget build(BuildContext context) => expand ? Expanded(child: child) : child;
}


class _LiveAcademicOverview extends StatefulWidget {
  const _LiveAcademicOverview();
  @override
  State<_LiveAcademicOverview> createState() => _LiveAcademicOverviewState();
}

class _LiveAcademicOverviewState extends State<_LiveAcademicOverview> {
  late DateTime _now;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final date = '${_weekday(_now.weekday)}, ${_now.day} ${_month(_now.month)} ${_now.year}';
    final time = '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}';
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(22)),
      child: LayoutBuilder(builder: (context, box) {
        final compact = box.maxWidth < 620;
        final clock = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TODAY AT SGU', style: TextStyle(color: AppTheme.red, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          const SizedBox(height: 8), Text(date, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.ink)),
          const SizedBox(height: 4), Text(time, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppTheme.navy)),
          const SizedBox(height: 4), const Text('Local device time • updates every second', style: TextStyle(color: AppTheme.muted, fontSize: 11)),
        ]);
        final profile = StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: user == null ? null : FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? const <String, dynamic>{};
            final name = (data['name'] ?? user?.displayName ?? 'Student').toString();
            final studentId = (data['studentId'] ?? '').toString();
            final programme = (data['programme'] ?? '').toString();
            return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.person_outline, color: AppTheme.red, size: 25), const SizedBox(height: 8),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy, fontSize: 16)),
              if (studentId.isNotEmpty) Text('Student ID: $studentId', style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
              if (programme.isNotEmpty) Text(programme, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
              if (snapshot.hasError) const Text('Profile details unavailable', style: TextStyle(color: AppTheme.muted, fontSize: 11)),
            ]));
          },
        );
        if (compact) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [clock, const SizedBox(height: 16), profile]);
        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(flex: 3, child: clock), const SizedBox(width: 20), Expanded(flex: 2, child: profile)]);
      }),
    );
  }
  String _weekday(int day) => const ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'][day - 1];
  String _month(int month) => const ['January','February','March','April','May','June','July','August','September','October','November','December'][month - 1];
}

class _LiveUpcomingEvents extends StatelessWidget {
  const _LiveUpcomingEvents();
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('calendarEvents').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _eventState('Campus events could not load. Check Firestore rules and connection.');
        if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
        final docs = (snapshot.data?.docs ?? []).where((doc) {
          final value = doc.data()['eventDate'];
          return value is Timestamp && !value.toDate().isBefore(start);
        }).toList()..sort((a, b) {
          final av = a.data()['eventDate'] as Timestamp;
          final bv = b.data()['eventDate'] as Timestamp;
          return av.compareTo(bv);
        });
        if (docs.isEmpty) return _eventState('No upcoming events have been published yet. Events added to the campus calendar will appear here automatically.');
        return Column(children: docs.take(5).map((doc) {
          final d = doc.data();
          final date = (d['eventDate'] as Timestamp).toDate().toLocal();
          final dateLabel = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
            leading: Container(width: 46, height: 46, decoration: BoxDecoration(color: AppTheme.paleRed, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.event_outlined, color: AppTheme.red)),
            title: Text((d['title'] ?? 'Campus event').toString(), style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy)),
            subtitle: Text('$dateLabel • ${(d['location'] ?? 'Campus').toString()}\n${(d['description'] ?? '').toString()}', maxLines: 2, overflow: TextOverflow.ellipsis),
            isThreeLine: true,
          ));
        }).toList());
      },
    );
  }
  Widget _eventState(String message) => Card(child: Padding(padding: const EdgeInsets.all(24), child: Row(children: [const Icon(Icons.event_busy_outlined, color: AppTheme.muted), const SizedBox(width: 12), Expanded(child: Text(message, style: const TextStyle(color: AppTheme.muted)))])));
}


class _LiveNextClassReminder extends StatelessWidget {
  const _LiveNextClassReminder({required this.onNavigate});
  final ValueChanged<String>? onNavigate;
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('formSubmissions').where('module', isEqualTo: 'Timetable').snapshots(),
    builder: (context, snapshot) {
      String title = 'No timetable entries published';
      String subtitle = 'Your timetable will appear here when the university adds schedule records.';
      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
        final data = snapshot.data!.docs.first.data();
        final fields = data['fields'] is Map ? Map<String, dynamic>.from(data['fields'] as Map) : <String, dynamic>{};
        title = (data['title'] ?? 'Timetable entry').toString();
        final details = [data['description'], ...fields.values].where((v) => v != null && v.toString().trim().isNotEmpty).map((v) => v.toString()).toList();
        subtitle = details.isEmpty ? 'Open your timetable to view this schedule record.' : details.take(3).join(' • ');
      } else if (snapshot.hasError) {
        subtitle = 'Could not load timetable records. Check Firestore rules and connection.';
      }
      return Material(color: AppTheme.paleRed, borderRadius: BorderRadius.circular(18), child: InkWell(
        onTap: () => onNavigate?.call('Timetable'), borderRadius: BorderRadius.circular(18),
        child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF5C5CC)), borderRadius: BorderRadius.circular(18)), child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.schedule_rounded, color: AppTheme.red, size: 24)),
          const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('TIMETABLE UPDATE', style: TextStyle(color: AppTheme.red, fontSize: 10, letterSpacing: .7, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5), Text(title, style: const TextStyle(color: AppTheme.ink, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
          ])), const Icon(Icons.arrow_forward_rounded, color: AppTheme.red),
        ])),
      ));
    },
  );
}
