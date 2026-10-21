# SGU Student Campus UI and Firestore implementation notes

- Kept the existing Firebase setup, authentication, repositories, routes and admin form-record screen.
- Added `lib/screens/routes/campus_explorer_screen.dart`: level selector (1–5), selectable illustrated map, place directory and selected place details.
- Added `Campus` to student navigation and connected the dashboard Explore Campus action to it.
- Updated campus event list to use large image-led cards and updated event details with a wide hero image. Event save behavior still writes to the signed-in user's `myEvents` Firestore collection.
- Updated service cards to be larger and adjusted request form student details to a responsive two-column layout on wide screens.
- Changed the student-shell timetable entry to use the dedicated timetable screen.
- Theme palette: background `#F5F6F8`, white surfaces, SGU red `#D32F2F`, dark red `#B71C1C`, pale red `#FCECEF`, text `#202126`, muted `#7A8495`, border `#E1E5EA`.

## Important limitations
- The campus floor plan is an illustrative directory, not a surveyed SGU map. Replace it with approved floor plans and verified room locations.
- Event cards reuse the available SGU campus image because the project only includes a campus image and logo asset. Add approved distinct event images for closer reference matching.
- Existing sample timetable/dashboard academic numbers must not be represented as live academic records unless connected to verified data.
- This environment did not have Flutter/Dart CLI available, so no `flutter analyze`, `flutter test`, desktop build or live Firebase runtime result is claimed. Run all commands in `PIXEL_MATCH_IMPLEMENTATION_PLAN.md` locally before deployment.
