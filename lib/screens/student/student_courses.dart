import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/course_card.dart';
import '../shared/course_workspace.dart';
import '../../widgets/common.dart';

class StudentCoursesPage extends StatelessWidget {
  const StudentCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: 'My Courses',
      subtitle: 'Courses you are enrolled in this semester.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1300 ? 4 : width >= 900 ? 3 : width >= 580 ? 2 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: MockData.i.courses.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: 292,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final course = MockData.i.courses[index];
              return CourseCard(
                course: course,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseWorkspacePage(courseId: course.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
