# Flutter analysis fixes in this package

Based on the `flutter analyze` output supplied by the project owner, this update addresses the reported Dart syntax/compile errors in:

- `lib/screens/shared/calendar.dart`: closes the dialog content widget correctly and uses `initialValue` for the dropdown.
- `lib/screens/shared/firebase_sign_in_screen.dart`: rewrites the sign-in screen widget tree with balanced widget closures.
- `lib/screens/student/student_profile.dart`: fixes the profile dialog widget nesting and phone-number regular expression.
- `lib/screens/teacher/teacher_profile.dart`: fixes the staff profile dialog nesting and rewrites the profile widget tree.
- `lib/screens/student/student_assignments.dart`: imports the models file that declares `RecordStatus`.
- `lib/widgets/firestore_module_records.dart`: rewrites the submission list builder with balanced widget closures and uses `initialValue` for dropdowns.

## Firebase configuration still required

`lib/firebase_options.dart` intentionally remains a placeholder until `flutterfire configure` is run against the owner's real Firebase project. Do not ship the app as connected until that command succeeds and the generated configuration is present.

## Verification status

The source changes above are based on the reported analyzer errors. This packaging environment does not have the Flutter/Dart CLI, so this package has not been independently confirmed with `flutter analyze`, platform builds, or Firebase Emulator tests. Run those checks on the development machine after configuration and share any remaining output. Analyzer `info` messages are style/deprecation notices, not compile errors.
