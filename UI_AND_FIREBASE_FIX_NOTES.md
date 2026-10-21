# UI and Firebase fixes (20 October 2026)

## Included in this update
- Redesigned the shared submission dialog with a white surface, rounded border, icon header, clear helper text, and section headings for the Requests module.
- Changed the Requests form to ask for a subject, description, service category, and priority. Students no longer select the request status; the service team/admin updates it.
- Tightened the course card layout to reduce vertical content and avoid the reported RenderFlex overflow.
- Removed an unnecessary Firestore import from the student profile screen.

## Required Firebase step for the profile permission error
The local `firestore.rules` file already allows an authenticated user to read their own `/users/{uid}` document. A `cloud_firestore/permission-denied` error on that profile query usually means the rules deployed to Firebase project `sguerp-35408` differ from the local rules, or the app is connected to a different Firebase project. This cannot be repaired by a UI-only code change.

From the project root, confirm `firebase use` points to `sguerp-35408`, inspect `firebase.json`, then deploy only the reviewed Firestore rules:

```powershell
firebase use sguerp-35408
firebase deploy --only firestore:rules --project sguerp-35408
```

Do not make the database public. After deployment, sign out/in or restart the app and test the profile with the same account. If it still fails, verify the Firebase project ID in `lib/firebase_options.dart` and the active project in Firebase Console.

## Validation status
The ZIP structure was checked, but Flutter/Dart CLI is not installed in this packaging environment. Run these commands on the Windows development machine:

```powershell
flutter pub get
flutter analyze
flutter run -d windows
```

Check the course cards at the same window size shown in the screenshots and confirm no overflow markers remain. The live Firebase rules deployment and profile read were not testable from this environment.
