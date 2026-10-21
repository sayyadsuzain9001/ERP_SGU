import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Interactive floor selector and illustrated campus directory.
/// Replace the illustrative floor plan with approved SGU maps when available.
class CampusExplorerScreen extends StatefulWidget {
  const CampusExplorerScreen({super.key});

  @override
  State<CampusExplorerScreen> createState() => _CampusExplorerScreenState();
}

class _CampusExplorerScreenState extends State<CampusExplorerScreen> {
  int _level = 1;
  String? _selectedPlace;

  final Map<int, List<_CampusPlace>> _places = const {
    1: [
      _CampusPlace('Main Entrance', 'Main visitor and student entrance', Icons.door_front_door_outlined),
      _CampusPlace('Student Services', 'Student help and administration', Icons.support_agent_outlined),
      _CampusPlace('Cafeteria', 'Food and refreshments', Icons.restaurant_outlined),
      _CampusPlace('Event Hall', 'Talks, workshops and campus events', Icons.groups_outlined),
    ],
    2: [
      _CampusPlace('Lecture Rooms', 'Teaching and seminar rooms', Icons.meeting_room_outlined),
      _CampusPlace('Computer Labs', 'Practical computer laboratories', Icons.computer_outlined),
      _CampusPlace('Faculty Offices', 'Academic staff offices', Icons.school_outlined),
      _CampusPlace('Study Lounge', 'Quiet student study space', Icons.weekend_outlined),
    ],
    3: [
      _CampusPlace('Library', 'Books, study spaces and research', Icons.local_library_outlined),
      _CampusPlace('Research Lab', 'Research and project facilities', Icons.science_outlined),
      _CampusPlace('Meeting Rooms', 'Group work and collaboration', Icons.groups_outlined),
      _CampusPlace('Student Lounge', 'Shared student space', Icons.weekend_outlined),
    ],
    4: [
      _CampusPlace('Innovation Hub', 'Project and startup workspace', Icons.lightbulb_outline),
      _CampusPlace('Seminar Room', 'Presentations and guest lectures', Icons.co_present_outlined),
      _CampusPlace('Faculty Area', 'Academic department offices', Icons.apartment_outlined),
      _CampusPlace('Quiet Study', 'Individual study space', Icons.menu_book_outlined),
    ],
    5: [
      _CampusPlace('Conference Hall', 'Large meetings and presentations', Icons.business_outlined),
      _CampusPlace('Project Studio', 'Team projects and innovation', Icons.devices_outlined),
      _CampusPlace('Staff Offices', 'Campus administration', Icons.badge_outlined),
      _CampusPlace('Open Terrace', 'Outdoor student break area', Icons.park_outlined),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final places = _places[_level]!;
    final selectedMatches = places.where((p) => p.name == _selectedPlace);
    final _CampusPlace? selected = selectedMatches.isEmpty ? null : selectedMatches.first;
    return PageContainer(
      title: 'Explore SGU Campus',
      subtitle: 'Choose a floor and select a location to explore the campus directory.',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('CAMPUS LEVELS', style: TextStyle(color: AppTheme.red, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: List.generate(5, (i) {
          final level = i + 1;
          return ChoiceChip(label: Text('Level $level'), selected: _level == level,
            selectedColor: AppTheme.red, labelStyle: TextStyle(color: _level == level ? Colors.white : AppTheme.ink, fontWeight: FontWeight.w700),
            onSelected: (_) => setState(() { _level = level; _selectedPlace = null; }));
        })),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 900;
          final map = _mapPanel(places);
          final directory = _directoryPanel(places, selected);
          if (!desktop) return Column(children: [map, const SizedBox(height: 14), directory]);
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 7, child: map), const SizedBox(width: 18), Expanded(flex: 3, child: directory)]);
        }),
        const SizedBox(height: 30),
        const Text('CAMPUS LIFE', style: TextStyle(color: AppTheme.red, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 8),
        const Text('Designed for more than classes.', style: TextStyle(fontSize: 28, color: AppTheme.ink, fontWeight: FontWeight.w500, letterSpacing: -.7)),
        const SizedBox(height: 6),
        const Text('Study, collaborate, research and explore university life.', style: TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 14),
        ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.network('https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=1600&q=85', height: 250, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, error, stack) => Container(height: 250, color: AppTheme.navy, child: const Icon(Icons.account_balance_outlined, size: 56, color: Colors.white)))),
      ]),
    );
  }

  Widget _mapPanel(List<_CampusPlace> places) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(24)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Expanded(child: Text('INTERACTIVE CAMPUS DIRECTORY', style: TextStyle(color: AppTheme.red, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .7))), Text('Level $_level', style: const TextStyle(fontWeight: FontWeight.w800))]),
      const SizedBox(height: 14),
      Container(height: 440, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: const Color(0xFFF4F2EF), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border)),
        child: LayoutBuilder(builder: (context, box) => Stack(children: [
          Positioned(left: box.maxWidth * .49, top: 20, bottom: 20, child: Container(width: 2, color: const Color(0xFFD9D5CF))),
          Positioned(top: box.maxHeight * .49, left: 20, right: 20, child: Container(height: 2, color: const Color(0xFFD9D5CF))),
          for (int i = 0; i < places.length; i++) _mapRoom(places[i], i, box.maxWidth, box.maxHeight),
          const Positioned(left: 18, bottom: 16, child: Chip(avatar: Icon(Icons.my_location, color: AppTheme.red, size: 16), label: Text('Campus directory', style: TextStyle(fontSize: 11)))),
        ])),
      ),
    ]),
  );

  Widget _mapRoom(_CampusPlace place, int index, double width, double height) {
    final selected = _selectedPlace == place.name;
    final left = index.isEven ? width * .08 : width * .57;
    final top = index < 2 ? height * .13 : height * .62;
    return Positioned(left: left, top: top, width: width * .32, height: height * .23,
      child: InkWell(onTap: () => setState(() => _selectedPlace = place.name), borderRadius: BorderRadius.circular(15),
        child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: selected ? AppTheme.paleRed : const Color(0xFFE8E6E2), border: Border.all(color: selected ? AppTheme.red : const Color(0xFFD7D3CD), width: selected ? 2 : 1), borderRadius: BorderRadius.circular(15)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(place.icon, color: AppTheme.red, size: 23), const SizedBox(height: 6), Text(place.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.ink))]))));
  }

  Widget _directoryPanel(List<_CampusPlace> places, _CampusPlace? selected) => Container(
    padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(24)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('LEVEL $_level', style: const TextStyle(color: AppTheme.red, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8)),
      const SizedBox(height: 6), const Text('Places', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.ink)),
      const SizedBox(height: 5), const Text('Select a location to see its details.', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
      const SizedBox(height: 16),
      for (final place in places) Padding(padding: const EdgeInsets.only(bottom: 9), child: Material(color: _selectedPlace == place.name ? AppTheme.paleRed : AppTheme.bg, borderRadius: BorderRadius.circular(14), child: InkWell(onTap: () => setState(() => _selectedPlace = place.name), borderRadius: BorderRadius.circular(14), child: Padding(padding: const EdgeInsets.all(13), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Icon(place.icon, color: AppTheme.red)), const SizedBox(width: 11), Expanded(child: Text(place.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))), const Icon(Icons.chevron_right, color: AppTheme.muted)]))))),
      if (selected != null) ...[
        const Divider(height: 22), Text(selected.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 6), Text(selected.description, style: const TextStyle(color: AppTheme.muted, fontSize: 12, height: 1.4)),
        const SizedBox(height: 12), const Row(children: [Icon(Icons.info_outline, color: AppTheme.red, size: 16), SizedBox(width: 6), Expanded(child: Text('Illustrative floor directory. Confirm room locations with SGU facilities.', style: TextStyle(color: AppTheme.muted, fontSize: 10)))])
      ]
    ]),
  );
}

class _CampusPlace {
  final String name;
  final String description;
  final IconData icon;
  const _CampusPlace(this.name, this.description, this.icon);
}
