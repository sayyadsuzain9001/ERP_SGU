import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import 'route_widgets.dart';

/// Large, image-led event cards inspired by the supplied reference screens.
class CampusEventsScreen extends StatelessWidget {
  const CampusEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = MockData.i.campusEventItems;
    return RoutePageFrame(
      title: 'Upcoming Events',
      subtitle: 'Discover academic, career and student opportunities at SGU.',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('WHAT’S HAPPENING', style: TextStyle(color: AppTheme.red, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 8),
        const Text('Find your next opportunity.', style: TextStyle(fontSize: 30, color: AppTheme.ink, fontWeight: FontWeight.w500, letterSpacing: -.7)),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1050 ? 3 : constraints.maxWidth >= 650 ? 2 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              mainAxisExtent: constraints.maxWidth < 650 ? 370 : 355,
            ),
            itemBuilder: (context, index) => _eventCard(context, events[index], index),
          );
        }),
      ]),
    );
  }

  Widget _eventCard(BuildContext context, CampusEventItem event, int index) {
    final label = event.category.toUpperCase();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 6, child: Stack(fit: StackFit.expand, children: [
            Image.network(_eventImage(index), fit: BoxFit.cover, errorBuilder: (_, error, stack) => Container(color: AppTheme.navy, child: Icon(event.icon, size: 42, color: Colors.white))),
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x12000000), Color(0x99000000)]))),
            Positioned(left: 15, top: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .96), borderRadius: BorderRadius.circular(30)), child: Text(label, style: const TextStyle(color: AppTheme.red, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .5)))),
            Positioned(left: 17, right: 17, bottom: 16, child: Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 22, height: 1.1, fontWeight: FontWeight.w800))),
          ])),
          Expanded(flex: 4, child: Padding(padding: const EdgeInsets.fromLTRB(17, 14, 17, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(event.dateLabel, style: const TextStyle(color: AppTheme.muted, fontSize: 12))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFE8F6EF), borderRadius: BorderRadius.circular(30)), child: const Text('Registration open', style: TextStyle(color: Color(0xFF238454), fontSize: 9, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 7),
            Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 12, height: 1.35)),
            const Spacer(),
            Row(children: [
              Expanded(child: Text('${event.time} · ${event.location}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 10))),
              TextButton.icon(onPressed: () => Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event), icon: const Icon(Icons.arrow_outward_rounded, size: 15), label: const Text('View event'), style: TextButton.styleFrom(foregroundColor: AppTheme.red, padding: EdgeInsets.zero)),
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
      'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=1200&q=85',
    ];
    return images[index % images.length];
  }

}
