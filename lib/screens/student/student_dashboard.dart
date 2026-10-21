import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';
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
        _nextClassReminder(context),
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
        GridView.count(
          crossAxisCount: width >= 1000 ? 3 : (width >= 650 ? 2 : 1),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: width < 650 ? 1.12 : (width < 1000 ? 1.05 : 1.28),
          children: MockData.i.campusEventItems.take(3).toList().asMap().entries
              .map((entry) => _eventCard(context, entry.value, entry.key)).toList(),
        ),
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

  Widget _overview() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(22)),
    child: LayoutBuilder(builder: (context, box) {
      final compact = box.maxWidth < 700;
      final metrics = const [
        ('SEMESTER', '6'), ('CGPA', '8.35'), ('CREDITS', '96'), ('ATTENDANCE', '82%'),
      ];
      return Flex(direction: compact ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          ExpandedIfNeeded(expand: !compact, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Your academic overview', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            SizedBox(height: 5), Text('Keep track of your progress throughout the semester.', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
          ])),
          SizedBox(width: compact ? 0 : 24, height: compact ? 18 : 0),
          if (compact) Wrap(spacing: 28, runSpacing: 18, children: metrics.map((m) => _metric(m.$1, m.$2)).toList())
          else ...metrics.map((m) => Expanded(child: _metric(m.$1, m.$2))),
        ],
      );
    }),
  );

  Widget _metric(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 9, letterSpacing: .7, fontWeight: FontWeight.w800, color: AppTheme.muted)),
    const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700, color: AppTheme.ink)),
  ]);

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

  Widget _nextClassReminder(BuildContext context) => Material(
    color: AppTheme.paleRed,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: () => onNavigate?.call('Timetable'),
      borderRadius: BorderRadius.circular(18),
      child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: AppTheme.paleRed,
      border: Border.all(color: const Color(0xFFF5C5CC)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(children: [
      Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.schedule_rounded, color: AppTheme.red, size: 24)),
      const SizedBox(width: 14),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NEXT CLASS REMINDER', style: TextStyle(color: AppTheme.red, fontSize: 10, letterSpacing: .7, fontWeight: FontWeight.w800)),
        SizedBox(height: 5),
        Text('Machine Learning · Today 11:30 AM · Lab 204', style: TextStyle(color: AppTheme.ink, fontSize: 14, fontWeight: FontWeight.w700)),
      ])),
      const Icon(Icons.arrow_forward_rounded, color: AppTheme.red),
    ]),
  ),
    ),
  );

  Widget _eventCard(BuildContext context, CampusEventItem event, int index) {
    final imageUrl = _eventImage(index);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 6, child: Stack(fit: StackFit.expand, children: [
            Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, error, stack) => Container(color: AppTheme.darkRed, child: Icon(event.icon, size: 42, color: Colors.white))),
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x16000000), Color(0x99000000)]))),
            Positioned(left: 15, top: 13, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .94), borderRadius: BorderRadius.circular(20)), child: Text(event.category.toUpperCase(), style: const TextStyle(color: AppTheme.red, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .6)))),
            Positioned(right: 14, top: 12, child: Icon(event.icon, color: Colors.white.withValues(alpha: .92), size: 27)),
            Positioned(left: 16, right: 16, bottom: 14, child: Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, height: 1.12))),
          ])),
          Expanded(flex: 4, child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 7), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 10, height: 1.2))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFE8F6EF), borderRadius: BorderRadius.circular(20)), child: const Text('Registration open', style: TextStyle(color: Color(0xFF238454), fontSize: 9, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: Text(event.dateLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 10))),
              TextButton.icon(onPressed: () => Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event), icon: const Icon(Icons.arrow_forward_rounded, size: 13), label: const Text('View event'), style: TextButton.styleFrom(foregroundColor: AppTheme.red, padding: EdgeInsets.zero, visualDensity: VisualDensity.compact, tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
            ]),
          ]))),
        ]),
      ),
    );
  }


  String _eventImage(int index) {
    const images = [
      'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=1200&q=85',
    ];
    return images[index % images.length];
  }

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
