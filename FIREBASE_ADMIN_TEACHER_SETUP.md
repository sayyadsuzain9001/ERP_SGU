# Admin and teacher account setup (secure)

## Are there preset credentials?
There are **no hard-coded admin or teacher email/password credentials** in this project. The Flutter app does not create an admin account automatically. A teacher can register, but registration records a pending request and does not grant teacher permissions.

## Create the accounts
1. In Firebase Console, open **Authentication → Users → Add user** and create an account for the intended admin. Save the email/password securely yourself.
2. Repeat for the intended teacher, or let the teacher register through the app.
3. From a trusted machine controlled by the Firebase project owner, use the Firebase Admin SDK to assign the appropriate custom claim. Never put a service-account JSON file in this ZIP, source control, Flutter assets, or the browser.

This project includes `scripts/set_user_role.js` as a trusted setup helper. Install Node.js and the Admin SDK in a separate secure admin workspace, configure `GOOGLE_APPLICATION_CREDENTIALS` to a service-account JSON file kept outside the project/repository, then run:

```bash
node scripts/set_user_role.js admin@example.com admin
node scripts/set_user_role.js teacher@example.com teacher
```

The Admin SDK package (`firebase-admin`) must be installed in that secure workspace. The service account must have permission to manage Firebase Authentication users. Replace the example email addresses with the actual accounts you created. Do not send passwords or service-account files in chat.

After setting the claim, each user must sign out and sign in again so the new token is loaded. Verify `role: admin` or `role: teacher` using a trusted admin process. Do not grant roles based only on an editable Firestore profile field.

## Profile photo upload
The crop-and-upload feature writes the cropped JPEG to `profilePhotos/{uid}/...` and saves its URL in `users/{uid}.photoUrl`. Deploy the project's Firestore and Storage rules to the same Firebase project configured in `lib/firebase_options.dart`:

```bash
firebase use sguerp-35408
firebase deploy --only firestore:rules,storage
```

Check the selected Firebase project before deploying. These rules should not be made public to fix a permission error.
