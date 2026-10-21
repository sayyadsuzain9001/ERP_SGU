# SGU Student Campus — UI and interaction update

## Updated in this package
- Sidebar navigation is prioritised: frequently used screens appear first; secondary academic, campus-life, finance/document, and personal/support screens are grouped under collapsible headings.
- Course cards have a larger image area and more usable card height, reducing the large empty white region visible in the supplied screenshot.
- Course cards use distinct subject-related image URLs rather than a repeated campus photograph.
- Dashboard event cards use the existing event model data and open the matching event detail screen.
- Event cards and event detail use different topic-appropriate online images instead of repeating the SGU campus photo.
- Campus-life tiles use separate images for academic spaces, technology labs, and library.
- Campus explorer uses a separate campus/academic building image for its banner.
- Dashboard quick-help, common-issues, request-status, and next-class cards now navigate to their matching portal screens.
- Sidebar navigation is still role-aware (student, teacher, admin); the less-frequently used links have not been deleted.

## Existing logic retained
- Campus service request form validates input and writes submissions to Firestore through the repository.
- Event detail has a Firebase action to save an event to the signed-in user's `myEvents` collection.
- The admin Form Records page reads `campusRequests` from Firestore and lets trusted admins update request status.

## Important boundaries
- The course catalogue and campus event catalogue still come from `MockData`; these are demo catalogue records, not live records managed in Firestore. The user's saved event list and campus request submissions are persisted in Firebase.
- Online image assets need an internet connection. They are hosted on Unsplash URLs; they are not embedded in the ZIP. If an image cannot load, the screen shows a fallback visual.
- A Firestore `permission-denied` error for Calendar normally means the rules currently deployed to Firebase do not match the local `firestore.rules`, or the user is not authenticated. This ZIP cannot deploy Firebase rules to the user's project automatically. From the project folder, review the rules and deploy with `firebase deploy --only firestore:rules` after confirming the project selection.
- This environment does not have the Flutter/Dart CLI available, so the package ZIP was integrity-tested, but `flutter analyze`, compilation, and live Firebase actions must still be run on the user's machine.


## Profile permission-error update
- The Profile page now keeps the Edit profile action available for a signed-in user even if the profile stream returns a Firestore permission error. This lets the user open the form and see/edit the account fields; saving still requires the correct deployed Firestore rules.
- The error text now identifies the exact `users/{uid}` profile document access issue and explains that the rules must be deployed to the `SGUERP` Firebase project. It explicitly warns against making Firestore public.
- Local `firestore.rules` already has owner-only read/create/update rules for `/users/{uid}`. If the screenshot still appears, the likely next step is deploying this project's rules to the same Firebase project configured in `firebase_options.dart`; code changes cannot update remote rules automatically.


## Profile photo crop and dashboard identity update
- The profile photo action now opens a crop dialog before upload, with zoom and horizontal/vertical positioning controls. The result is encoded as JPEG and uploaded to a unique per-user Firebase Storage path to avoid stale browser image cache.
- Profile photo upload updates both `users/{uid}.photoUrl` and the signed-in Firebase Auth photo URL.
- Dashboard hero copy is now `Learn. Connect. Make Your Mark. At SGU.` with revised SGU-specific supporting text.
- Profile photo uploads require the local `storage.rules` to be deployed to the configured Firebase project. The signed-in user can only upload into their own `profilePhotos/{uid}/` path.
- There are no hard-coded admin or teacher email/password credentials in the project. Teacher self-registration is pending approval and does not grant the trusted `teacher` claim. Admin and teacher permissions must be assigned by a trusted Firebase Admin SDK process; do not place passwords or service-account keys in the Flutter app or ZIP.
