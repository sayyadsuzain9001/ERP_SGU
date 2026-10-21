/**
 * Assign a trusted Firebase custom claim to an existing Firebase Auth user.
 * Run only on a trusted administrator machine. Never ship service-account keys
 * in the Flutter app or commit them to source control.
 *
 * Usage:
 *   npm install firebase-admin
 *   GOOGLE_APPLICATION_CREDENTIALS="/secure/path/service-account.json" node scripts/set_firebase_role.js USER_UID student
 * Allowed roles: student, teacher, admin
 */
const admin = require('firebase-admin');

async function main() {
  const [, , uid, role] = process.argv;
  const allowed = new Set(['student', 'teacher', 'admin']);
  if (!uid || !allowed.has(role)) {
    throw new Error('Usage: node scripts/set_firebase_role.js USER_UID student|teacher|admin');
  }
  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    throw new Error('Set GOOGLE_APPLICATION_CREDENTIALS to a secure service-account JSON path.');
  }
  admin.initializeApp({ credential: admin.credential.applicationDefault() });
  await admin.auth().setCustomUserClaims(uid, { role });
  console.log(`Assigned Firebase custom claim role=${role} to UID ${uid}. Ask the user to sign out and sign in again.`);
}

main().catch((error) => { console.error(error.message); process.exitCode = 1; });
