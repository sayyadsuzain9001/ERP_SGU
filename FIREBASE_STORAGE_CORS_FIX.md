# Firebase Storage CORS and dashboard overflow fix

## Why the profile picture upload is failing
The browser upload request from your local Flutter web origin is being rejected during the CORS preflight. The screenshot shows the origin `http://localhost:55842`. Configure CORS on the Storage bucket and deploy the Storage rules. CORS and Firebase Storage Security Rules are separate: both must allow the request.

## 1. Configure bucket CORS (run from a terminal with Google Cloud CLI installed and authenticated)

From the project root, run:

```powershell
gcloud storage buckets update gs://sguerp-35408.firebasestorage.app --cors-file=storage.cors.json
```

If your installed `gcloud` version does not support `--cors-file`, use a current Google Cloud CLI. Confirm the bucket name in Firebase Console > Storage before running this. Only use the bucket name shown for your project.

For production, add your deployed website's exact HTTPS origin to `origin`; do not use `*` for authenticated profile uploads. The local ports above cover the common local development ports including the one in the console screenshot. If Flutter chooses another port, add that exact origin and reapply the CORS file.

## 2. Deploy Storage rules

```powershell
firebase deploy --only storage --project sguerp-35408
```

Rules are in `storage.rules`. Confirm the signed-in user is uploading to `profilePhotos/<their-auth-uid>/<filename>` and that the file is JPEG, PNG, or WebP and no larger than 5 MB. CORS does not override Security Rules.

## 3. Restart and test

1. Stop Flutter (`Ctrl+C`).
2. Run `flutter run -d chrome --web-port 55842` to keep the origin stable.
3. Sign in, select a profile image, crop it, and upload.
4. Check Firebase Console > Storage for `profilePhotos/<uid>/...`.

If it still fails, open the failed request in DevTools > Network and check the response/status. A `403` usually means rules/auth/bucket configuration; a preflight failure means the bucket CORS configuration still does not match the actual origin or headers. Never make the bucket public to solve this.

## Dashboard layout
The event card's lower content padding and text/button sizing were reduced to address the reported 8.8-pixel vertical `RenderFlex` overflow at `student_dashboard.dart` around line 232. Run `flutter analyze` and check the dashboard at the same viewport size after extracting this ZIP.
