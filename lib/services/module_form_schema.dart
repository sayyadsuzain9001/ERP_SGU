/// Small purpose-built field sets for the modules currently routed through the
/// reusable Firestore form screen. Values are stored in Firestore `fields`.
class ModuleFieldSpec {
  const ModuleFieldSpec(this.key, this.label, {this.required = false, this.options = const []});
  final String key;
  final String label;
  final bool required;
  final List<String> options;
  bool get isChoice => options.isNotEmpty;
}

const Map<String, List<ModuleFieldSpec>> moduleFormSchemas = {
  'Students': [ModuleFieldSpec('studentId', 'Student ID', required: true), ModuleFieldSpec('email', 'Student email', required: true), ModuleFieldSpec('programme', 'Programme', required: true), ModuleFieldSpec('recordStatus', 'Status', required: true, options: ['Active', 'On Leave', 'Graduated', 'Suspended'])],
  'Teachers': [ModuleFieldSpec('staffId', 'Staff ID', required: true), ModuleFieldSpec('email', 'Work email', required: true), ModuleFieldSpec('department', 'Department', required: true), ModuleFieldSpec('recordStatus', 'Status', required: true, options: ['Active', 'On Leave', 'Inactive'])],
  'Staff': [ModuleFieldSpec('staffId', 'Staff ID', required: true), ModuleFieldSpec('email', 'Work email'), ModuleFieldSpec('department', 'Department', required: true), ModuleFieldSpec('recordStatus', 'Status', required: true, options: ['Active', 'On Leave', 'Inactive'])],
  'Courses': [ModuleFieldSpec('courseCode', 'Course code', required: true), ModuleFieldSpec('credits', 'Credits', required: true), ModuleFieldSpec('instructor', 'Instructor', required: true), ModuleFieldSpec('semester', 'Semester', required: true)],
  'My Courses': [ModuleFieldSpec('courseCode', 'Course code', required: true), ModuleFieldSpec('instructor', 'Instructor'), ModuleFieldSpec('semester', 'Semester')],
  'Departments': [ModuleFieldSpec('departmentCode', 'Department code', required: true), ModuleFieldSpec('headOfDepartment', 'Head of department'), ModuleFieldSpec('email', 'Contact email')],
  'Programmes': [ModuleFieldSpec('programmeCode', 'Programme code', required: true), ModuleFieldSpec('department', 'Department', required: true), ModuleFieldSpec('duration', 'Duration', required: true)],
  'Subjects': [ModuleFieldSpec('subjectCode', 'Subject code', required: true), ModuleFieldSpec('courseCode', 'Course code', required: true), ModuleFieldSpec('credits', 'Credits', required: true)],
  'Timetable': [ModuleFieldSpec('courseCode', 'Course code', required: true), ModuleFieldSpec('day', 'Day', required: true, options: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']), ModuleFieldSpec('time', 'Time', required: true), ModuleFieldSpec('room', 'Room / lab', required: true)],
  'Exams': [ModuleFieldSpec('courseCode', 'Course code', required: true), ModuleFieldSpec('examDate', 'Exam date', required: true), ModuleFieldSpec('time', 'Time', required: true), ModuleFieldSpec('venue', 'Venue', required: true)],
  'Exam Schedule': [ModuleFieldSpec('courseCode', 'Course code', required: true), ModuleFieldSpec('examDate', 'Exam date', required: true), ModuleFieldSpec('time', 'Time', required: true), ModuleFieldSpec('venue', 'Venue', required: true)],
  'Academic Calendar': [ModuleFieldSpec('eventDate', 'Date', required: true), ModuleFieldSpec('category', 'Category', required: true, options: ['Semester', 'Holiday', 'Exam', 'Registration', 'Deadline'])],
  'Calendar': [ModuleFieldSpec('eventDate', 'Date', required: true), ModuleFieldSpec('category', 'Category', required: true, options: ['Academic', 'Exam', 'Club', 'Campus', 'Deadline'])],
  'Assignments': [ModuleFieldSpec('courseCode', 'Course code', required: true), ModuleFieldSpec('dueDate', 'Due date', required: true), ModuleFieldSpec('maxMarks', 'Maximum marks', required: true), ModuleFieldSpec('recordStatus', 'Status', required: true, options: ['Draft', 'Published', 'Closed'])],
  'Create Assignment': [ModuleFieldSpec('courseCode', 'Course code', required: true), ModuleFieldSpec('dueDate', 'Due date', required: true), ModuleFieldSpec('maxMarks', 'Maximum marks', required: true)],
  'Submissions': [ModuleFieldSpec('studentId', 'Student ID', required: true), ModuleFieldSpec('assignmentTitle', 'Assignment', required: true), ModuleFieldSpec('recordStatus', 'Status', required: true, options: ['Submitted', 'Late', 'Marked for review', 'Graded'])],
  'Grades': [ModuleFieldSpec('studentId', 'Student ID', required: true), ModuleFieldSpec('courseCode', 'Course code', required: true), ModuleFieldSpec('grade', 'Grade', required: true), ModuleFieldSpec('marks', 'Marks', required: true)],
  'Grading': [ModuleFieldSpec('studentId', 'Student ID', required: true), ModuleFieldSpec('courseCode', 'Course code', required: true), ModuleFieldSpec('grade', 'Grade', required: true), ModuleFieldSpec('feedback', 'Feedback')],
  'Attendance': [ModuleFieldSpec('courseCode', 'Course code', required: true), ModuleFieldSpec('classDate', 'Class date', required: true), ModuleFieldSpec('presentCount', 'Present count'), ModuleFieldSpec('totalCount', 'Total students')],
  'Announcements': [ModuleFieldSpec('audience', 'Audience', required: true, options: ['All students', 'Teachers', 'Staff', 'Specific course']), ModuleFieldSpec('publishDate', 'Publish date'), ModuleFieldSpec('recordStatus', 'Status', required: true, options: ['Draft', 'Published', 'Archived'])],
  'Events': [ModuleFieldSpec('eventDate', 'Event date', required: true), ModuleFieldSpec('location', 'Location'), ModuleFieldSpec('category', 'Category', required: true, options: ['Academic', 'Sports', 'Club', 'Campus'])],
  'Facilities': [ModuleFieldSpec('facilityType', 'Facility type', required: true, options: ['Classroom', 'Lab', 'Sports', 'Hostel', 'Transport', 'Other']), ModuleFieldSpec('location', 'Location', required: true), ModuleFieldSpec('recordStatus', 'Status', required: true, options: ['Available', 'Maintenance', 'Unavailable'])],
  'Finance': [ModuleFieldSpec('studentId', 'Student ID', required: true), ModuleFieldSpec('amount', 'Amount (RM)', required: true), ModuleFieldSpec('feeType', 'Fee type', required: true), ModuleFieldSpec('recordStatus', 'Status', required: true, options: ['Pending', 'Paid', 'Overdue', 'Waived'])],
  'Fee Summary': [ModuleFieldSpec('feeType', 'Fee type', required: true), ModuleFieldSpec('amount', 'Amount (RM)', required: true), ModuleFieldSpec('dueDate', 'Due date')],
  'Payment History': [ModuleFieldSpec('transactionId', 'Transaction ID', required: true), ModuleFieldSpec('amount', 'Amount (RM)', required: true), ModuleFieldSpec('paymentDate', 'Payment date'), ModuleFieldSpec('recordStatus', 'Status', required: true, options: ['Pending', 'Paid', 'Failed', 'Refunded'])],
  'Receipts': [ModuleFieldSpec('transactionId', 'Transaction ID', required: true), ModuleFieldSpec('amount', 'Amount (RM)', required: true), ModuleFieldSpec('paymentDate', 'Payment date')],
  'Requests': [ModuleFieldSpec('requestType', 'Service category', required: true, options: ['Academic Support', 'IT Helpdesk', 'Library Services', 'Accommodation', 'Finance', 'Campus Facilities', 'Other']), ModuleFieldSpec('priority', 'Priority', required: true, options: ['Low', 'Normal', 'High'])],
  'Course Registration': [ModuleFieldSpec('studentId', 'Student ID', required: true), ModuleFieldSpec('courseCode', 'Course code', required: true), ModuleFieldSpec('semester', 'Semester', required: true)],
  'Library': [ModuleFieldSpec('resourceType', 'Resource type', required: true, options: ['Book', 'Journal', 'Digital resource', 'Equipment']), ModuleFieldSpec('resourceCode', 'Resource code'), ModuleFieldSpec('dueDate', 'Due date')],
  'Hostel': [ModuleFieldSpec('block', 'Hostel block'), ModuleFieldSpec('room', 'Room preference'), ModuleFieldSpec('term', 'Term / semester', required: true)],
  'Transport': [ModuleFieldSpec('route', 'Route', required: true), ModuleFieldSpec('pickupPoint', 'Pickup point', required: true), ModuleFieldSpec('term', 'Term / semester')],
  'Clubs': [ModuleFieldSpec('clubName', 'Club name', required: true), ModuleFieldSpec('membershipType', 'Membership type', required: true, options: ['Join', 'Renew', 'Withdraw'])],
  'Cafeteria': [ModuleFieldSpec('vendor', 'Vendor / outlet'), ModuleFieldSpec('requestType', 'Request type', required: true, options: ['Feedback', 'Meal plan', 'Dietary request', 'Other'])],
  'Documents': [ModuleFieldSpec('documentType', 'Document type', required: true), ModuleFieldSpec('purpose', 'Purpose', required: true)],
  'Career': [ModuleFieldSpec('opportunityType', 'Opportunity type', required: true, options: ['Internship', 'Job', 'Career counselling', 'Workshop']), ModuleFieldSpec('company', 'Company / provider')],
  'Tasks': [ModuleFieldSpec('dueDate', 'Due date'), ModuleFieldSpec('priority', 'Priority', required: true, options: ['Low', 'Normal', 'High']), ModuleFieldSpec('recordStatus', 'Status', required: true, options: ['To do', 'In progress', 'Done'])],
  'Messages': [ModuleFieldSpec('recipient', 'Recipient', required: true), ModuleFieldSpec('subject', 'Subject', required: true)],
  'Notifications': [ModuleFieldSpec('audience', 'Audience', required: true), ModuleFieldSpec('category', 'Category', required: true), ModuleFieldSpec('recordStatus', 'Status', required: true, options: ['Unread', 'Read', 'Archived'])],
  'Help & Support': [ModuleFieldSpec('category', 'Support category', required: true, options: ['Technical', 'Academic', 'Finance', 'Account', 'Other']), ModuleFieldSpec('priority', 'Priority', required: true, options: ['Low', 'Normal', 'High'])],
  'Settings': [ModuleFieldSpec('settingKey', 'Setting name', required: true), ModuleFieldSpec('settingValue', 'Setting value', required: true)],
  'Audit Logs': [ModuleFieldSpec('action', 'Action', required: true), ModuleFieldSpec('target', 'Target record'), ModuleFieldSpec('recordStatus', 'Outcome', required: true, options: ['Success', 'Failed', 'Review'])],
  'Reports': [ModuleFieldSpec('reportType', 'Report type', required: true), ModuleFieldSpec('period', 'Reporting period', required: true)],
  'Course Workspace': [ModuleFieldSpec('courseCode', 'Course code', required: true), ModuleFieldSpec('term', 'Term / semester', required: true)],
  'Course Materials': [ModuleFieldSpec('courseCode', 'Course code', required: true), ModuleFieldSpec('resourceType', 'Material type', required: true, options: ['Lecture notes', 'Slides', 'Reading', 'Video', 'Other'])],
};

List<ModuleFieldSpec> fieldsForModule(String module) => moduleFormSchemas[module] ?? const [
  ModuleFieldSpec('category', 'Category'),
  ModuleFieldSpec('reference', 'Related course / reference'),
];
