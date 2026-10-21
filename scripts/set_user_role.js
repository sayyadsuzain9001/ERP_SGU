
/**
 * Trusted admin-only role setup utility.
 * Run only on your trusted computer.
 *
 * Usage:
 * node scripts/set_user_role.js email@example.com admin
 *
 * Requires GOOGLE_APPLICATION_CREDENTIALS to point to
 * a Firebase Admin service-account JSON file.
 */

const { initializeApp, applicationDefault } =
  require('firebase-admin/app');

const { getAuth } = require('firebase-admin/auth');

async function main() {
  const [email, role] = process.argv.slice(2);

  if (!email || !['admin', 'teacher', 'student'].includes(role)) {
    console.error(
      'Usage: node scripts/set_user_role.js <email> <admin|teacher|student>'
    );
    process.exitCode = 1;
    return;
  }

  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    console.error(
      'Set GOOGLE_APPLICATION_CREDENTIALS to your service-account JSON path first.'
    );
    process.exitCode = 1;
    return;
  }

  initializeApp({
    credential: applicationDefault(),
    projectId: 'sguerp-35408',
  });

  const auth = getAuth();
  const user = await auth.getUserByEmail(email);

  const claims = { ...(user.customClaims || {}) };

  if (role === 'student') {
    delete claims.role;
  } else {
    claims.role = role;
  }

  await auth.setCustomUserClaims(user.uid, claims);

  console.log(`Role '${role}' assigned to ${email}.`);
  console.log(`Firebase UID: ${user.uid}`);
  console.log(
    'Sign out and sign in again to refresh the user token.'
  );
}

main().catch((error) => {
  console.error('Role assignment failed:', error.message || error);
  process.exitCode = 1;
});
