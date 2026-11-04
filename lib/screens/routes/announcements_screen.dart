import 'package:flutter/material.dart';

import '../../models/campus_content.dart';
import '../../theme/app_theme.dart';
import 'route_widgets.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final Set<String> _bookmarkedIds = <String>{};

  @override
  Widget build(BuildContext context) {
    return RoutePageFrame(
      title: 'Announcements',
      subtitle: 'Campus updates and information for SGU students.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LATEST UPDATES',
            style: TextStyle(
              color: AppTheme.red,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Stay informed',
            style: TextStyle(
              color: AppTheme.navy,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ListView.builder(
            itemCount: campusAnnouncements.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = campusAnnouncements[index];
              final saved = _bookmarkedIds.contains(item.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.paleRed,
                    child: Icon(item.icon, color: AppTheme.red),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      color: AppTheme.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      '${item.category} • ${item.date}\n${item.preview}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: saved ? 'Remove bookmark' : 'Bookmark',
                    icon: Icon(
                      saved ? Icons.bookmark : Icons.bookmark_border,
                      color: saved ? AppTheme.red : AppTheme.muted,
                    ),
                    onPressed: () {
                      setState(() {
                        if (saved) {
                          _bookmarkedIds.remove(item.id);
                        } else {
                          _bookmarkedIds.add(item.id);
                        }
                      });
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AnnouncementDetailScreen(item: item),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Demonstration content for the SGU Student Campus app.',
            style: TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({super.key, required this.item});

  final CampusAnnouncement item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcement details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundColor: AppTheme.paleRed,
                      child: Icon(item.icon, color: AppTheme.red, size: 28),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      item.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: AppTheme.navy,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(item.date, style: const TextStyle(color: AppTheme.muted)),
                    const Divider(height: 30),
                    Text(
                      item.detail,
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to announcements'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Demonstration content for the SGU Student Campus app.',
                      style: TextStyle(color: AppTheme.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
