import 'package:flutter_test/flutter_test.dart';
import 'package:sgu_student_campus/main.dart';

void main() {
  testWidgets('SGU Student Campus loads', (tester) async {
    await tester.pumpWidget(const SGUStudentCampusApp());
    expect(find.text('SGU Student Campus'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
  });
}
