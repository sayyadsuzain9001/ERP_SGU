# SGU Student Campus — implementation and verification status

## Firebase-only architecture

- Firebase Authentication: email/password identity and auth-state routing.
- Cloud Firestore: profiles, campus service requests, module form submissions, calendar events, saved events and assignment submission metadata.
- Firebase Storage: upload integration exists in source, but **real uploads are blocked until Storage is available for the project's billing plan**. The user selected the Spark/free plan and Firebase Console displayed a billing/Blaze requirement. Do not claim file upload is working on Spark.
- No Supabase, MongoDB, PostgreSQL or alternative backend is used.

## Implemented in the source package

- Email/password sign-in, registration, password reset and sign-out UI wired to Firebase Authentication.
- Role lookup uses trusted Firebase Authentication custom claims (`role: student|teacher|admin`). UI role selectors are not authorization.
- Reusable, validated module forms with module-specific fields for many student, teacher and admin modules; create/edit/list/delete saves to Firestore `formSubmissions`.
- Student and teacher profile editing saves to Firestore `users/{uid}`.
- Campus service requests save to Firestore `campusRequests`.
- Assignment submission metadata is designed to save to Firestore; actual binary file upload uses Firebase Storage and therefore requires Storage to be enabled under a compatible plan. On the current Spark setup, do not treat file upload as available.
- Calendar event create/list/delete and saved “My Events” create/list/delete use Firestore.
- Firestore and Storage security rules use owner checks and trusted role claims; client-supplied role labels are not trusted.
- Route `/profile` and portal profile page share the Firebase-backed profile screen.
- Added `scripts/set_firebase_role.js` for trusted custom-claim assignment and setup documentation.
- Removed hard-coded example progress, timetable, result and finance metrics from the generic module workspace so they are not shown as real records.

## Not complete / requires real project access or more domain work

- `lib/firebase_options.dart` is a deliberate placeholder. The actual Firebase project ID/platform configuration must be generated locally using `flutterfire configure`; this cannot be safely invented or generated without access to the user's local Firebase account and selected platforms.
- Firestore and Storage rules still need deployment to the user's `SGUERP` Firebase project. Do not deploy until the selected project ID is verified.
- Assign trusted role claims to real user UIDs from a trusted environment. Never ship service-account credentials in Flutter.
- Several purpose-built screens still contain mock data or static display elements (including dashboard summaries, courses, attendance, timetable, results, finance, campus catalog and course workspace). These are not all migrated to live Firestore collections yet.
- The generic form collection is not a replacement for all domain workflows. Course enrolment relationships/capacity checks, gradebook calculation and release, attendance per student/session, payment processing and reconciliation, official event publishing/moderation, and teacher assignment review/grading remain incomplete.
- File upload cannot be verified or used on the current Spark setup while the Console requires Blaze for Storage. Metadata-only submission is not equivalent to a real file upload.
- Navigation and security rules have not been exercised against a running app/Firebase Emulator in this environment.
- Flutter/Dart CLI was unavailable here. `flutter pub get`, `flutter analyze`, platform builds, widget tests, Firebase Emulator tests and device end-to-end tests have not been run. This package must not be represented as a fully runtime-verified release.

## Setup steps

1. Install Flutter and verify `flutter --version`.
2. From the folder containing `pubspec.yaml`, run `dart pub global activate flutterfire_cli` and `flutterfire configure`; choose the user's existing `SGUERP` project and intended platforms. This replaces the placeholder `lib/firebase_options.dart`.
3. Confirm Authentication → Email/Password is enabled (user has shown this enabled) and Cloud Firestore exists (user has shown the default database created).
4. Keep the Spark plan if required. With current Console gating, do not expect Firebase Storage uploads to work. Firestore forms can still be tested.
5. Verify the active Firebase project ID, then run `firebase use --add` and `firebase deploy --only firestore:rules` from the project folder. Deploy Storage rules only after Storage is available and the target project is verified.
6. Create test accounts, assign role custom claims from a trusted environment, then sign out/in to refresh tokens.
7. Run `flutter pub get`, `dart format lib test`, `flutter analyze`, and `flutter test`; resolve errors before building.
8. Run Firestore rules tests in the Firebase Emulator and test every route and form on target platforms.
