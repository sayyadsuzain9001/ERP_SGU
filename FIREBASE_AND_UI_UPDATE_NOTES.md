# SGU Student Campus — Firebase and UI update notes

## Included in this update
- Registration now asks for full name, account type (Student or Teacher/Faculty), email, password, phone, and student/programme or staff/department details.
- New account profiles are written to `users/{uid}` in Cloud Firestore. A teacher selection is stored as `requestedRole: teacher` and `roleApprovalStatus: pending`; it does not grant teacher permissions. Trusted Firebase custom claims remain the authority for access.
- Student profile reads a live Firestore stream and displays actual Firebase Auth email/UID. It shows a clear permission/rules message rather than silently displaying fake profile data when Firestore denies access.
- Desktop sidebar can be hidden/shown using the hamburger button; mobile uses the drawer. Duplicate practical route/profile entries were removed from navigation.
- Shared page content uses a wider responsive container. My Courses uses responsive fixed-count grids and course cards with restrained remote subject images plus offline fallbacks.
- FlutterFire configuration is set to project `sguerp-35408` for the platforms shown in the user's generated config.

## Required one-time Firebase step
The profile permission error usually means the current rules in the Firebase Console differ from the local `firestore.rules`. From the project root, run:

```powershell
firebase deploy --only firestore:rules --project=sguerp-35408
```

Review the rules before deploying. Do not set public read/write access. This command deploys Firestore rules only; it does not enable Firebase Storage.

## Important role/security notes
- Selecting Teacher during sign-up is a request, not authorization. A trusted administrator must assign the Firebase custom claim `role=teacher` through a secure Admin SDK environment. Never put service-account credentials in the Flutter app.
- Do not rely on the debug-only portal preview menu for real permissions; it is for UI preview only.
- Firebase Storage in this project requires the billing setup shown by the Firebase Console. The project remains on Spark per user request, so actual Storage uploads are not considered available or tested.

## Validation status
The user previously reported `flutter analyze` with no issues on their local project before these UI/account updates. This environment does not have Flutter/Dart installed, so the new changes must be checked locally:

```powershell
flutter pub get
flutter analyze
flutter run -d windows
```

Then test registration, profile stream, profile editing, and a Firestore form. The Firebase Auth Windows channel warning observed earlier is a plugin/platform-channel warning; this source update does not claim to fix that plugin-level warning.
