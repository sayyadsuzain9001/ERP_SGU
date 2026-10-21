# GitHub Pages + Firebase: live form data

The GitHub repository or GitHub Pages only hosts the Flutter Web files. It does **not** store form submissions. The app writes and reads form submissions from the configured Cloud Firestore database in Firebase project `sguerp-35408`.

## What this project does

- Initializes Firebase with `lib/firebase_options.dart` on Web, Windows, Android, iOS and macOS.
- Writes module forms to the Firestore `formSubmissions` collection.
- Waits for Firestore's write acknowledgement, then reads the new document using `Source.server` before showing success.
- Uses a Firestore `snapshots()` query to keep the form-record list updated when the database changes.
- Filters records by module on Firestore. Students query only documents with their own `ownerUid`; trusted admin/teacher custom claims are used for staff queries.

## Required Firebase Console setup

1. Open Firebase Console and select **`sguerp-35408`**. Confirm that this is the same project used by `lib/firebase_options.dart`.
2. In **Build → Authentication → Sign-in method**, enable every sign-in provider the app uses. This project can fall back to anonymous sign-in for the generic module forms, so enable **Anonymous** if that fallback is used.
3. In **Authentication → Settings → Authorized domains**, add the exact GitHub Pages hostname, normally `YOUR-USERNAME.github.io`. If the app is served from a custom domain, add that domain too. Do not add a URL path such as `/sgu_student_campus/`; add only the hostname.
4. In **Firestore Database → Rules**, publish the reviewed rules from `firestore.rules`. Do not use public read/write rules. The rules in this project restrict student data and rely on trusted Firebase custom claims for staff access.
5. In Firestore Data, verify that successful form submissions appear under **`formSubmissions`**. The separate student service-request workflow may use **`campusRequests`**; do not confuse the two collections.
6. If the browser reports `permission-denied`, check the deployed rules, signed-in UID, collection path and whether the account has the expected trusted custom claim. Do not make the database public to silence the error.

## Build for GitHub Pages

Run these commands from the Flutter project root. Replace `YOUR-REPOSITORY` with the exact GitHub repository name (case-sensitive where the host requires it):

```powershell
flutter pub get
flutter analyze
flutter build web --release --base-href "/YOUR-REPOSITORY/"
```

For a user/organization site served from the root domain, use `--base-href "/"` instead. Publish the contents of `build/web` using the repository's GitHub Pages workflow or Pages deployment settings. The app must be served over HTTPS by GitHub Pages; do not open `index.html` directly from the file system.

## Verify end-to-end

1. Open the published HTTPS GitHub Pages URL and sign in.
2. Submit a test form with non-sensitive test data.
3. Wait for the app's success confirmation. This confirms the document write and server read succeeded.
4. Open Firebase Console → Firestore Database → Data → `formSubmissions`; confirm the document and fields exist.
5. Return to the app. The form records list uses a live Firestore stream and should update as the database emits changes.
6. Change a test document from Firebase Console and confirm the list refreshes, provided the signed-in account is permitted to read that document.
7. Test with a student account and an admin/teacher account separately. Never rely on a role selected in the UI; staff permissions must come from trusted Firebase custom claims.

## Troubleshooting

- **Firebase app fails to initialize:** check `lib/firebase_options.dart` and ensure the Web `projectId` is `sguerp-35408`.
- **`auth/unauthorized-domain`:** add the exact hostname to Firebase Authentication's authorized domains.
- **`permission-denied`:** publish the correct `firestore.rules` to the same Firebase project and confirm the account's UID/claims. Do not open access publicly.
- **Submission succeeds locally but not on the website:** ensure the deployed site was rebuilt from this code and that browser developer tools do not show an auth, network, or Firestore error.
- **GitHub Pages shows 404 for app assets:** rebuild with the correct `--base-href` matching the repository path.
- **No records are visible:** confirm the page is reading the expected collection (`formSubmissions` versus `campusRequests`) and that the signed-in account is authorized to read those records.

## Security reminder

Firebase Web configuration is client configuration, not a service-account secret. Firestore Security Rules and Authentication control access. Never commit service-account JSON, admin private keys, passwords, or real student information to GitHub.
