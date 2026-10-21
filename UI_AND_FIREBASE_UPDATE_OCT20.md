# SGU Student Campus – UI and Firebase update

## Changes in this update

- Student Profile now supports uploading a profile picture to Firebase Storage (maximum 5 MB) and displays a student ID card with the user's name, student ID, programme, semester, email, and profile picture.
- Profile and account details remain editable through the existing profile editor.
- Campus Service Request attempts to prefill the signed-in student's name, student ID, email, and phone from Firebase Authentication and `users/{uid}`. If Firestore access is not configured yet, the fields remain editable.
- Event details now include an Event Registration dialog. It prefills account/profile data, validates required fields, writes a registration record to `eventRegistrations`, and adds the event to `myEvents`.
- Request verification page has a clearer success state and a more polished summary card.
- Course workspace has a visible Back to Courses action and a more useful responsive overview with course progress and shortcuts.
- Dashboard hero spacing and height were adjusted to reduce the small-screen-height overflow shown in the supplied screenshot.
- Firestore rules now include owner-scoped event registrations and allow the signed-in user to save their own `photoUrl`. Storage rules include owner-scoped profile photo uploads.

## Run and deploy on the developer machine

From the project folder:

```powershell
flutter pub get
flutter analyze
flutter run -d chrome
```

Use `flutter run -d windows` if testing the Windows desktop build.

Before testing profile photos and event registration, verify the selected Firebase project:

```powershell
firebase use
```

Then deploy the included security rules to that intended project:

```powershell
firebase deploy --only firestore:rules,storage
```

Do not make Firestore or Storage public to bypass permission errors. Profile reads and writes are intended to remain owner-scoped; administrator access depends on trusted custom claims.

## Test checklist

1. Sign in with a normal student account.
2. Open Profile, complete missing profile details, upload a JPG/PNG/WebP image smaller than 5 MB, and open the Student ID Card.
3. Open Campus Service Request and confirm the saved name, ID, email, and phone are prefilled. Submit a valid test request and confirm the professional success/verification page appears.
4. Open Events, open an event, select Register for Event, verify the prefilled data, and confirm registration. Check the user's `eventRegistrations` and `myEvents` records in Firestore.
5. Open My Courses, enter a course, use Back to Courses, and test the overview at narrow and wide window sizes.
6. Resize the browser vertically and verify the dashboard hero no longer shows a yellow/black overflow warning.

## Validation status

The ZIP structure is checked for archive integrity. Flutter/Dart CLI was not available in the packaging environment, so `flutter analyze`, desktop/web compilation, and live Firebase tests must still be run locally. Firebase rules in the ZIP are not deployed automatically by downloading it.
