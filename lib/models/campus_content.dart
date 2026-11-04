import 'package:flutter/material.dart';

class CampusAnnouncement {
  const CampusAnnouncement({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.preview,
    required this.detail,
    required this.icon,
  });

  final String id;
  final String title;
  final String category;
  final String date;
  final String preview;
  final String detail;
  final IconData icon;
}

const List<CampusAnnouncement> campusAnnouncements = [
  CampusAnnouncement(
    id: 'library-hours',
    title: 'Library Hours Extended',
    category: 'Library',
    date: '28 Oct 2026',
    preview: 'The Central Library will offer extended study hours this week.',
    detail: 'The Central Library will remain open for extended study hours this week to support students preparing for assessments. Please check the library desk for the daily closing time.',
    icon: Icons.local_library_outlined,
  ),
  CampusAnnouncement(
    id: 'exam-registration',
    title: 'Examination Registration',
    category: 'Academics',
    date: '27 Oct 2026',
    preview: 'Check your examination registration and student details.',
    detail: 'Students should review their examination registration and verify that their personal and course details are correct. Contact the academic office if any correction is needed.',
    icon: Icons.assignment_outlined,
  ),
  CampusAnnouncement(
    id: 'career-workshop',
    title: 'Career Preparation Workshop',
    category: 'Career',
    date: '26 Oct 2026',
    preview: 'Join a workshop on CV writing and interview preparation.',
    detail: 'Career Services is hosting a student workshop covering CV structure, interview preparation and professional communication. Contact Career Services for registration details.',
    icon: Icons.work_outline,
  ),
  CampusAnnouncement(
    id: 'sports-registration',
    title: 'Inter-Department Sports',
    category: 'Sports',
    date: '25 Oct 2026',
    preview: 'Registration is open for upcoming inter-department activities.',
    detail: 'Students interested in participating in inter-department sports activities can contact the Sports Office. Team registration and event details are available at the sports desk.',
    icon: Icons.sports_soccer_outlined,
  ),
  CampusAnnouncement(
    id: 'it-maintenance',
    title: 'IT System Maintenance',
    category: 'IT Services',
    date: '24 Oct 2026',
    preview: 'Some campus IT services may be briefly unavailable during maintenance.',
    detail: 'Scheduled maintenance may temporarily affect selected campus IT services. Save your work in advance and contact the IT Helpdesk if you experience an issue after the maintenance window.',
    icon: Icons.computer_outlined,
  ),
  CampusAnnouncement(
    id: 'counselling-support',
    title: 'Student Counselling Support',
    category: 'Student Support',
    date: '23 Oct 2026',
    preview: 'Students can contact the Counselling Centre for support.',
    detail: 'The Student Counselling Centre provides personal and academic support. Students can contact the centre to ask about available appointments and support services.',
    icon: Icons.support_agent_outlined,
  ),
  CampusAnnouncement(
    id: 'hostel-maintenance',
    title: 'Hostel Maintenance Requests',
    category: 'Accommodation',
    date: '22 Oct 2026',
    preview: 'Submit room maintenance concerns through the accommodation office.',
    detail: 'Students living in university accommodation can report room maintenance concerns to the Accommodation Office. Include your room details and a short description of the issue.',
    icon: Icons.home_work_outlined,
  ),
  CampusAnnouncement(
    id: 'student-project-showcase',
    title: 'Student Project Showcase',
    category: 'Campus Life',
    date: '21 Oct 2026',
    preview: 'Students are invited to share projects and ideas at the campus showcase.',
    detail: 'The student project showcase invites students to present academic projects, prototypes and creative work. Contact the organising team for participation guidance and scheduling.',
    icon: Icons.lightbulb_outline,
  ),
];
