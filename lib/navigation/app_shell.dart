import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

import '../screens/student/student_dashboard.dart';
import '../screens/student/student_courses.dart';
import '../screens/student/student_assignments.dart';
import '../screens/student/student_attendance.dart';
import '../screens/student/student_timetable.dart';
import '../screens/student/student_progress.dart';
import '../screens/student/student_registration.dart';
import '../screens/student/student_exams.dart';
import '../screens/student/student_hall_ticket.dart';
import '../screens/student/student_results.dart';
import '../screens/student/student_transcript.dart';
import '../screens/student/student_calendar.dart';
import '../screens/student/student_clubs.dart';
import '../screens/student/student_library.dart';
import '../screens/student/student_hostel.dart';
import '../screens/student/student_transport.dart';
import '../screens/student/student_cafeteria.dart';
import '../screens/student/student_finance.dart';
import '../screens/student/student_documents.dart';
import '../screens/student/student_career.dart';
import '../screens/student/student_notifications.dart';
import '../screens/student/student_tasks.dart';
import '../screens/student/student_messages.dart';
import '../screens/student/student_requests.dart';
import '../screens/student/student_profile.dart';
import '../screens/student/student_settings.dart';
import '../screens/student/student_help_support.dart';

import '../screens/teacher/teacher_dashboard.dart';
import '../screens/teacher/teacher_courses.dart';
import '../screens/teacher/teacher_assignments.dart';
import '../screens/teacher/teacher_submissions.dart';
import '../screens/teacher/teacher_grading.dart';
import '../screens/teacher/teacher_attendance.dart';
import '../screens/teacher/teacher_students.dart';
import '../screens/teacher/teacher_materials.dart';
import '../screens/teacher/teacher_calendar.dart';
import '../screens/teacher/teacher_analytics.dart';
import '../screens/teacher/teacher_profile.dart';
import '../screens/teacher/teacher_settings.dart';
import '../screens/teacher/teacher_help_support.dart';

import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_students.dart';
import '../screens/admin/admin_teachers.dart';
import '../screens/admin/admin_staff.dart';
import '../screens/admin/admin_courses.dart';
import '../screens/admin/admin_departments.dart';
import '../screens/admin/admin_programmes.dart';
import '../screens/admin/admin_subjects.dart';
import '../screens/admin/admin_timetable.dart';
import '../screens/admin/admin_exams.dart';
import '../screens/admin/admin_academic_calendar.dart';
import '../screens/admin/admin_assignments.dart';
import '../screens/admin/admin_submissions.dart';
import '../screens/admin/admin_grades.dart';
import '../screens/admin/admin_attendance.dart';
import '../screens/admin/admin_announcements.dart';
import '../screens/admin/admin_events.dart';
import '../screens/admin/admin_facilities.dart';
import '../screens/admin/admin_finance.dart';
import '../screens/admin/admin_requests.dart';
import '../screens/admin/admin_form_records.dart';
import '../screens/admin/admin_reports.dart';
import '../screens/admin/admin_notifications.dart';
import '../screens/admin/admin_audit_logs.dart';
import '../screens/admin/admin_settings.dart';
import '../screens/admin/admin_help_support.dart';

import '../screens/shared/course_workspace.dart';
import '../screens/shared/module_pages.dart';
import '../screens/shared/notifications.dart';
import '../screens/shared/messages.dart';
import '../screens/forms/campus_service_request_screen.dart';
import '../screens/routes/campus_services_screen.dart';
import '../screens/routes/campus_explorer_screen.dart';
import '../screens/routes/campus_events_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  UserRole role = UserRole.student;
  String selected = 'Dashboard';
  bool _sidebarExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadTrustedRole();
  }

  Future<void> _loadTrustedRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final claims = (await user.getIdTokenResult(true)).claims ?? const <String, dynamic>{};
      final nextRole = switch (claims['role']) {
        'teacher' => UserRole.teacher,
        'admin' => UserRole.admin,
        _ => UserRole.student,
      };
      if (mounted) setState(() { role = nextRole; selected = 'Dashboard'; });
    } catch (_) {
      if (mounted) setState(() => role = UserRole.student);
    }
  }

  List<NavItem> get navItems {
    switch (role) {
      case UserRole.student:
        return const [
          NavItem('Dashboard', Icons.dashboard_outlined),
          NavItem('My Courses', Icons.menu_book_outlined),
          NavItem('Assignments', Icons.assignment_outlined),
          NavItem('Attendance', Icons.fact_check_outlined),
          NavItem('Timetable', Icons.schedule_outlined),
          NavItem('Academic Progress', Icons.trending_up_outlined),
          NavItem('Course Registration', Icons.app_registration_outlined),
          NavItem('Exam Schedule', Icons.event_note_outlined),
          NavItem('Hall Ticket', Icons.badge_outlined),
          NavItem('Results', Icons.assessment_outlined),
          NavItem('Transcript', Icons.description_outlined),
          NavItem('Calendar', Icons.calendar_month_outlined),
          NavItem('Events', Icons.event_outlined),
          NavItem('Campus', Icons.map_outlined),
          NavItem('Campus Services', Icons.support_agent_outlined),
          NavItem('Service Request Form', Icons.assignment_outlined),
          NavItem('Clubs', Icons.groups_outlined),
          NavItem('Library', Icons.local_library_outlined),
          NavItem('Hostel', Icons.hotel_outlined),
          NavItem('Transport', Icons.directions_bus_outlined),
          NavItem('Cafeteria', Icons.restaurant_outlined),
          NavItem('Fee Summary', Icons.account_balance_wallet_outlined),
          NavItem('Payment History', Icons.payments_outlined),
          NavItem('Receipts', Icons.receipt_long_outlined),
          NavItem('Documents', Icons.folder_outlined),
          NavItem('Career', Icons.work_outline),
          NavItem('Notifications', Icons.notifications_none_rounded),
          NavItem('Tasks', Icons.task_alt_outlined),
          NavItem('Messages', Icons.message_outlined),
          NavItem('Requests', Icons.support_agent_outlined),
          NavItem('Profile', Icons.person_outline),
          NavItem('Settings', Icons.settings_outlined),
          NavItem('Help & Support', Icons.help_outline_rounded),
        ];
      case UserRole.teacher:
        return const [
          NavItem('Dashboard', Icons.dashboard_outlined),
          NavItem('My Courses', Icons.menu_book_outlined),
          NavItem('Course Workspace', Icons.school_outlined),
          NavItem('Assignments', Icons.assignment_outlined),
          NavItem('Create Assignment', Icons.add_task_outlined),
          NavItem('Submissions', Icons.inbox_outlined),
          NavItem('Grading', Icons.grading_outlined),
          NavItem('Attendance', Icons.fact_check_outlined),
          NavItem('Students', Icons.people_outline),
          NavItem('Course Materials', Icons.folder_copy_outlined),
          NavItem('Calendar', Icons.calendar_month_outlined),
          NavItem('Analytics', Icons.analytics_outlined),
          NavItem('Notifications', Icons.notifications_none_rounded),
          NavItem('Messages', Icons.message_outlined),
          NavItem('Profile', Icons.person_outline),
          NavItem('Settings', Icons.settings_outlined),
          NavItem('Help & Support', Icons.help_outline),
        ];
      case UserRole.admin:
        return const [
          NavItem('Dashboard', Icons.dashboard_outlined),
          NavItem('Students', Icons.people_outline),
          NavItem('Teachers', Icons.co_present_outlined),
          NavItem('Staff', Icons.badge_outlined),
          NavItem('Courses', Icons.school_outlined),
          NavItem('Departments', Icons.account_tree_outlined),
          NavItem('Programmes', Icons.account_balance_outlined),
          NavItem('Subjects', Icons.menu_book_outlined),
          NavItem('Timetable', Icons.schedule_outlined),
          NavItem('Exams', Icons.event_note_outlined),
          NavItem('Academic Calendar', Icons.calendar_month_outlined),
          NavItem('Assignments', Icons.assignment_outlined),
          NavItem('Submissions', Icons.inbox_outlined),
          NavItem('Grades', Icons.grading_outlined),
          NavItem('Attendance', Icons.fact_check_outlined),
          NavItem('Announcements', Icons.campaign_outlined),
          NavItem('Events', Icons.event_outlined),
          NavItem('Facilities', Icons.business_outlined),
          NavItem('Finance', Icons.account_balance_wallet_outlined),
          NavItem('Requests', Icons.support_agent_outlined),
          NavItem('Form Records', Icons.storage_outlined),
          NavItem('Reports', Icons.bar_chart_outlined),
          NavItem('Notifications', Icons.notifications_none_rounded),
          NavItem('Audit Logs', Icons.history_outlined),
          NavItem('Settings', Icons.settings_outlined),
          NavItem('Help & Support', Icons.help_outline),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1000;
        return Scaffold(
          appBar: _topBar(desktop),
          drawer: desktop ? null : _drawer(),
          body: Row(
            children: [
              if (desktop && _sidebarExpanded) AnimatedContainer(duration: const Duration(milliseconds: 180), width: 218, child: _sidebar()),
              Expanded(child: _page()),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _topBar(bool desktop) {
    return AppBar(
      toolbarHeight: 68,
      leading: Builder(
        builder: (context) => IconButton(
          tooltip: desktop ? (_sidebarExpanded ? 'Hide navigation' : 'Show navigation') : 'Open navigation',
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            if (desktop) {
              setState(() => _sidebarExpanded = !_sidebarExpanded);
            } else {
              Scaffold.of(context).openDrawer();
            }
          },
        ),
      ),
      titleSpacing: desktop ? 22 : 4,
      title: Row(
        children: [
          Image.asset('assets/images/sgu_logo.png', width: 34, height: 34),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SGU Student Campus',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              Text(
                'University ERP Portal',
                style: TextStyle(fontSize: 10, color: AppTheme.muted),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (desktop)
          SizedBox(
            width: 250,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: TextField(
                onSubmitted: _searchPortal,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          )
        else
          IconButton(
            tooltip: 'Search',
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
          ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => setState(() => selected = 'Notifications'),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        if (kDebugMode)
          PopupMenuButton<UserRole>(
            tooltip: 'Demo portal preview (not an access grant)',
            onSelected: (value) => setState(() { role = value; selected = 'Dashboard'; }),
            itemBuilder: (context) => const [
              PopupMenuItem(value: UserRole.student, child: Text('Student Portal preview')),
              PopupMenuItem(value: UserRole.teacher, child: Text('Teacher Portal preview')),
              PopupMenuItem(value: UserRole.admin, child: Text('Admin Portal preview')),
            ],
            child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: CircleAvatar(radius: 17, backgroundColor: Color(0xFFFFE1E1), child: Text('SGU', style: TextStyle(color: AppTheme.darkRed, fontSize: 9, fontWeight: FontWeight.w800)))),
          )
        else
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: CircleAvatar(radius: 17, backgroundColor: Color(0xFFFFE1E1), child: Text('SGU', style: TextStyle(color: AppTheme.darkRed, fontSize: 9, fontWeight: FontWeight.w800)))),
        IconButton(
          tooltip: 'Sign out',
          onPressed: () async { await FirebaseAuth.instance.signOut(); },
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }

  Widget _sidebar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppTheme.border)),
      ),
      child: _navList(),
    );
  }

  Widget _drawer() {
    return Drawer(child: SafeArea(child: _navList()));
  }

  Widget _navList() {
    final portal = switch (role) {
      UserRole.student => 'STUDENT PORTAL',
      UserRole.teacher => 'TEACHER PORTAL',
      UserRole.admin => 'ADMIN PORTAL',
    };

    final List<String> primaryLabels;
    final List<(String, IconData, List<String>)> groups;
    switch (role) {
      case UserRole.student:
        primaryLabels = const ['Dashboard', 'My Courses', 'Assignments', 'Timetable', 'Academic Progress', 'Events', 'Campus', 'Campus Services', 'Service Request Form'];
        groups = const [
          ('ACADEMICS', Icons.school_outlined, ['Attendance', 'Course Registration', 'Exam Schedule', 'Hall Ticket', 'Results', 'Transcript', 'Calendar']),
          ('CAMPUS LIFE', Icons.explore_outlined, ['Clubs', 'Library', 'Hostel', 'Transport', 'Cafeteria', 'Career']),
          ('PERSONAL & SUPPORT', Icons.person_outline, ['Notifications', 'Tasks', 'Messages', 'Requests', 'Profile', 'Settings', 'Help & Support']),
          ('FINANCE & DOCUMENTS', Icons.folder_outlined, ['Fee Summary', 'Payment History', 'Receipts', 'Documents']),
        ];
      case UserRole.teacher:
        primaryLabels = const ['Dashboard', 'My Courses', 'Course Workspace', 'Assignments', 'Submissions', 'Attendance', 'Students'];
        groups = const [
          ('TEACHING TOOLS', Icons.school_outlined, ['Create Assignment', 'Grading', 'Course Materials', 'Calendar', 'Analytics']),
          ('PERSONAL & SUPPORT', Icons.person_outline, ['Notifications', 'Messages', 'Profile', 'Settings', 'Help & Support']),
        ];
      case UserRole.admin:
        primaryLabels = const ['Dashboard', 'Students', 'Teachers', 'Courses', 'Events', 'Requests', 'Form Records'];
        groups = const [
          ('ACADEMIC MANAGEMENT', Icons.school_outlined, ['Staff', 'Departments', 'Programmes', 'Subjects', 'Timetable', 'Exams', 'Academic Calendar', 'Assignments', 'Submissions', 'Grades', 'Attendance']),
          ('CAMPUS & REPORTING', Icons.business_outlined, ['Announcements', 'Facilities', 'Finance', 'Reports', 'Audit Logs']),
          ('PERSONAL & SUPPORT', Icons.person_outline, ['Notifications', 'Settings', 'Help & Support']),
        ];
    }
    final itemsByLabel = {for (final item in navItems) item.label: item};
    final primaryItems = primaryLabels.map((label) => itemsByLabel[label]).whereType<NavItem>().toList();

    return Material(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 20),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 14),
            child: Text(portal, style: const TextStyle(fontSize: 11, color: AppTheme.muted, fontWeight: FontWeight.w800, letterSpacing: .6)),
          ),
          for (final item in primaryItems) _navTile(item),
          const SizedBox(height: 8),
          const Divider(indent: 10, endIndent: 10),
          for (final group in groups)
            _navGroup(group.$1, group.$2, group.$3.map((label) => itemsByLabel[label]).whereType<NavItem>().toList()),
          const SizedBox(height: 14),
          const Divider(indent: 10, endIndent: 10),
          ListTile(
            dense: true,
            leading: const Icon(Icons.account_circle_outlined, color: AppTheme.muted),
            title: const Text('Account', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.navy)),
            subtitle: Text(FirebaseAuth.instance.currentUser?.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
            onTap: () {
              setState(() => selected = 'Profile');
              if (MediaQuery.sizeOf(context).width < 1000 && Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _navGroup(String title, IconData icon, List<NavItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    final containsSelected = items.any((item) => item.label == selected);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey<String>('nav-$title'),
        initiallyExpanded: containsSelected,
        tilePadding: const EdgeInsets.symmetric(horizontal: 10),
        childrenPadding: const EdgeInsets.only(left: 8),
        leading: Icon(icon, size: 19, color: AppTheme.muted),
        title: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .45, color: AppTheme.muted)),
        children: [for (final item in items) _navTile(item)],
      ),
    );
  }

  Widget _navTile(NavItem item) {
    final active = selected == item.label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        selected: active,
        selectedTileColor: AppTheme.paleRed,
        leading: Icon(
          item.icon,
          size: 20,
          color: active ? AppTheme.red : AppTheme.muted,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppTheme.red : AppTheme.navy,
          ),
        ),
        onTap: () {
          setState(() => selected = item.label);
          if (Navigator.canPop(context) &&
              MediaQuery.sizeOf(context).width < 1000) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _page() {
    switch (role) {
      case UserRole.student:
        return _studentPage();
      case UserRole.teacher:
        return _teacherPage();
      case UserRole.admin:
        return _adminPage();
    }
  }

  Widget _studentPage() {
    switch (selected) {
      case 'Dashboard':
        return StudentDashboard(
          onNavigate: (page) => setState(() => selected = page),
        );
      case 'My Courses':
        return const StudentCoursesPage();
      case 'Assignments':
        return const StudentAssignmentsPage();
      case 'Attendance':
        return const StudentAttendancePage();
      case 'Timetable':
        return const StudentTimetablePage();
      case 'Academic Progress':
        return const StudentProgressPage();
      case 'Course Registration':
        return const StudentRegistrationPage();
      case 'Exam Schedule':
        return const StudentExamsPage();
      case 'Hall Ticket':
        return const StudentHallTicketPage();
      case 'Results':
        return const StudentResultsPage();
      case 'Transcript':
        return const StudentTranscriptPage();
      case 'Calendar':
        return const StudentCalendarPage();
      case 'Events':
        return const CampusEventsScreen();
      case 'Campus':
        return const CampusExplorerScreen();
      case 'Campus Services':
        return const CampusServicesScreen();
      case 'Service Request Form':
        return const CampusServiceRequestScreen();
      case 'Clubs':
        return const StudentClubsPage();
      case 'Library':
        return const StudentLibraryPage();
      case 'Hostel':
        return const StudentHostelPage();
      case 'Transport':
        return const StudentTransportPage();
      case 'Cafeteria':
        return const StudentCafeteriaPage();
      case 'Fee Summary':
        return const StudentFinancePage();
      case 'Payment History':
        return const StudentFinancePage();
      case 'Receipts':
        return const StudentFinancePage();
      case 'Documents':
        return const StudentDocumentsPage();
      case 'Career':
        return const StudentCareerPage();
      case 'Notifications':
        return const StudentNotificationsPage();
      case 'Tasks':
        return const StudentTasksPage();
      case 'Messages':
        return const StudentMessagesPage();
      case 'Requests':
        return const StudentRequestsPage();
      case 'Profile':
        return const StudentProfilePage();
      case 'Settings':
        return const StudentSettingsPage();
      case 'Help & Support':
        return const StudentHelpSupportPage();
      default:
        return GenericModulePage(title: selected, role: role);
    }
  }

  Widget _teacherPage() {
    switch (selected) {
      case 'Dashboard':
        return const TeacherDashboardPage();
      case 'My Courses':
        return const TeacherCoursesPage();
      case 'Course Workspace':
        return const CourseWorkspacePage(courseId: 'ml');
      case 'Assignments':
        return const TeacherAssignmentsPage();
      case 'Create Assignment':
        return const TeacherAssignmentsPage();
      case 'Submissions':
        return const TeacherSubmissionsPage();
      case 'Grading':
        return const TeacherGradingPage();
      case 'Attendance':
        return const TeacherAttendancePage();
      case 'Students':
        return const TeacherStudentsPage();
      case 'Course Materials':
        return const TeacherMaterialsPage();
      case 'Calendar':
        return const TeacherCalendarPage();
      case 'Analytics':
        return const TeacherAnalyticsPage();
      case 'Notifications':
        return const NotificationsPage();
      case 'Messages':
        return const MessagesPage();
      case 'Profile':
        return const TeacherProfilePage();
      case 'Settings':
        return const TeacherSettingsPage();
      case 'Help & Support':
        return const TeacherHelpSupportPage();
      default:
        return GenericModulePage(title: selected, role: role);
    }
  }

  Widget _adminPage() {
    switch (selected) {
      case 'Dashboard':
        return const AdminDashboardPage();
      case 'Students':
        return const AdminStudentsPage();
      case 'Teachers':
        return const AdminTeachersPage();
      case 'Staff':
        return const AdminStaffPage();
      case 'Courses':
        return const AdminCoursesPage();
      case 'Departments':
        return const AdminDepartmentsPage();
      case 'Programmes':
        return const AdminProgrammesPage();
      case 'Subjects':
        return const AdminSubjectsPage();
      case 'Timetable':
        return const AdminTimetablePage();
      case 'Exams':
        return const AdminExamsPage();
      case 'Academic Calendar':
        return const AdminAcademicCalendarPage();
      case 'Assignments':
        return const AdminAssignmentsPage();
      case 'Submissions':
        return const AdminSubmissionsPage();
      case 'Grades':
        return const AdminGradesPage();
      case 'Attendance':
        return const AdminAttendancePage();
      case 'Announcements':
        return const AdminAnnouncementsPage();
      case 'Events':
        return const AdminEventsPage();
      case 'Facilities':
        return const AdminFacilitiesPage();
      case 'Finance':
        return const AdminFinancePage();
      case 'Requests':
        return const AdminRequestsPage();
      case 'Form Records':
        return const AdminFormRecordsPage();
      case 'Reports':
        return const AdminReportsPage();
      case 'Notifications':
        return const AdminNotificationsPage();
      case 'Audit Logs':
        return const AdminAuditLogsPage();
      case 'Settings':
        return const AdminSettingsPage();
      case 'Help & Support':
        return const AdminHelpSupportPage();
      default:
        return GenericModulePage(title: selected, role: role);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _searchPortal(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final matches = navItems.where(
      (item) => item.label.toLowerCase().contains(normalized),
    );
    if (matches.isEmpty) {
      _snack('No portal page matches "$query".');
      return;
    }
    setState(() => selected = matches.first.label);
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController();
    final query = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Search portal pages'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter a page name',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Search'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (query != null) _searchPortal(query);
  }
}

class NavItem {
  final String label;
  final IconData icon;
  const NavItem(this.label, this.icon);
}
