# Connect SGU Student Campus to Firebase (Spark/free plan)

This project uses Firebase only: Authentication and Cloud Firestore. The source also contains a Firebase Storage upload integration, but the current Firebase Console says Storage requires Blaze/billing. If you stay on Spark, real file uploads are unavailable in this project setup. Do not upgrade unless you choose to accept billing.

## 1. Generate your actual Firebase options

Open PowerShell/VS Code terminal in the project folder (the folder containing `pubspec.yaml`):

```powershell
dart --version
flutter --version
dart pub global activate flutterfire_cli
flutterfire configure
```

Select the existing `SGUERP` project and target platforms. FlutterFire generates `lib/firebase_options.dart`. The checked-in file is intentionally a placeholder; the project cannot initialise Firebase until this step is complete. Do not invent API keys or project IDs.

## 2. Verify Firebase services

- Authentication → Sign-in method → Email/Password should be enabled (user confirmed this in Firebase Console).
- Cloud Firestore should exist (user confirmed the `(default)` database is created in production mode).
- Storage is currently blocked by the Console's billing requirement on Spark. Keep the free plan if required; use Firestore for forms and metadata, but do not promise actual file upload until Storage is available.

## 3. Deploy Firestore rules carefully

Install Firebase CLI if needed, then:

```powershell
npm install -g firebase-tools
firebase login
firebase use --add
```

Select the exact `SGUERP` Firebase project and verify its project ID before deployment. Then deploy Firestore rules:

```powershell
firebase deploy --only firestore:rules
```

Only deploy Storage rules if Storage is actually enabled and the correct project is selected:

```powershell
firebase deploy --only storage
```

Never use open test rules or deploy to an unrelated/production project without approval.

## 4. Trusted role claims

The app uses custom claims `role: student`, `role: teacher`, or `role: admin`. A client-side dropdown is not authorization. After the user accounts are created, assign claims from a trusted administrator environment using `scripts/set_firebase_role.js` and Firebase Admin SDK. Keep service-account JSON outside the Flutter project and never commit or share it. After a role is changed, sign out and sign back in to refresh the ID token.

## 5. Local checks

```powershell
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk
```

Run Firebase Emulator security tests and manual tests for registration, sign-in, reset password, profile editing, service requests, module create/edit/delete, calendar/My Events, role denial cases and all navigation routes. These commands have not been run in the package-preparation environment because Flutter/Dart were unavailable there.
