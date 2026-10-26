import assert from 'node:assert/strict';

const project = process.env.GCLOUD_PROJECT;
assert.equal(project, 'demo-campus-bobo', 'Run this test with the local demo project.');
const authHost = process.env.FIREBASE_AUTH_EMULATOR_HOST;
const firestoreHost = process.env.FIRESTORE_EMULATOR_HOST;
assert.ok(authHost && firestoreHost, 'Authentication and Firestore emulators must be running.');
const documents = `projects/${project}/databases/(default)/documents`;
const base = `http://${firestoreHost}/v1/${documents}`;

async function account(name, { verified = true, domain = 'alustudent.com' } = {}) {
  const endpoint = `http://${authHost}/identitytoolkit.googleapis.com/v1/accounts`;
  const credentials = { email: `${name}@${domain}`, password: 'CampusTest123!', returnSecureToken: true };
  let response = await fetch(`${endpoint}:signUp?key=local-test`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(credentials),
  });
  assert.ok(response.ok, 'Local account creation failed.');
  const user = await response.json();
  if (verified) {
    response = await fetch(`${endpoint}:update?key=local-test`, {
      method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: 'Bearer owner' },
      body: JSON.stringify({ localId: user.localId, emailVerified: true }),
    });
    assert.ok(response.ok, 'Local email verification failed.');
    response = await fetch(`${endpoint}:signInWithPassword?key=local-test`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(credentials),
    });
    assert.ok(response.ok, 'Local sign-in failed.');
    user.idToken = (await response.json()).idToken;
  }
  return { uid: user.localId, token: user.idToken, email: credentials.email };
}

function fields(data) {
  return Object.fromEntries(Object.entries(data).map(([key, value]) => [key, { stringValue: value }]));
}

async function write(user, path, data, { create = false, timestamps = ['updatedAt'] } = {}) {
  const update = { name: `${documents}/${path}`, fields: fields(data) };
  const operation = { update, updateTransforms: timestamps.map(fieldPath => ({ fieldPath, setToServerValue: 'REQUEST_TIME' })) };
  if (create) operation.currentDocument = { exists: false };
  else {
    operation.currentDocument = { exists: true };
    operation.updateMask = { fieldPaths: Object.keys(data) };
  }
  return fetch(`${base}:commit`, {
    method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${user.token}` },
    body: JSON.stringify({ writes: [operation] }),
  });
}

async function expectResult(response, allowed, message) {
  const body = await response.json();
  assert.equal(response.status, allowed ? 200 : 403, `${message}: ${body.error?.message ?? response.status}`);
  console.log(`PASS: ${message}`);
  return body;
}

async function profile(user) {
  await expectResult(await write(user, `users/${user.uid}`, {
    email: user.email, displayName: 'Campus Test', role: 'student',
  }, { create: true, timestamps: ['createdAt'] }), true, 'Verified student creates a student profile');
}

async function remove(user, id) {
  return fetch(`${base}/incidents/${id}`, { method: 'DELETE', headers: { Authorization: `Bearer ${user.token}` } });
}

const owner = await account('owner');
const other = await account('other');
const staff = await account('staff');
const unverified = await account('unverified', { verified: false });
const external = await account('external', { domain: 'example.com' });
for (const user of [owner, other, staff]) await profile(user);
await expectResult(await write({ token: 'owner' }, `users/${staff.uid}`, { role: 'staff' }, { timestamps: [] }), true, 'Administrator assigns the staff role');
await expectResult(await write(owner, `users/${owner.uid}`, { role: 'staff' }, { timestamps: [] }), false, 'Student cannot promote their own role');
for (const user of [unverified, external]) {
  await expectResult(await write(user, `users/${user.uid}`, { email: user.email, displayName: 'Campus Test', role: 'student' }, { create: true, timestamps: ['createdAt'] }), false, 'Unverified or external user cannot create a campus profile');
}

const draft = { reportedBy: owner.uid, title: 'Broken tap', description: 'The tap beside the entrance keeps leaking.', location: 'Block A', category: 'water', status: 'submitted' };
await expectResult(await write(owner, 'incidents/report-1', draft, { create: true, timestamps: ['createdAt', 'updatedAt'] }), true, 'Owner creates a submitted report');
await expectResult(await write(other, 'incidents/forged-owner', draft, { create: true, timestamps: ['createdAt', 'updatedAt'] }), false, 'Student cannot forge report ownership');
await expectResult(await write(owner, 'incidents/forged-status', { ...draft, status: 'resolved' }, { create: true, timestamps: ['createdAt', 'updatedAt'] }), false, 'A new report cannot start as resolved');
await expectResult(await write(owner, 'incidents/invalid-title', { ...draft, title: '' }, { create: true, timestamps: ['createdAt', 'updatedAt'] }), false, 'Invalid incident fields are rejected');
await expectResult(await write(owner, 'incidents/report-1', { title: 'Leaking tap near stairs' }), true, 'Owner edits their submitted report');
await expectResult(await write(other, 'incidents/report-1', { title: 'Changed by another student' }), false, 'Other students cannot edit a report');
await expectResult(await write(owner, 'incidents/report-1', { reportedBy: other.uid }), false, 'Owner cannot transfer ownership');
await expectResult(await write(owner, 'incidents/report-1', { createdAt: 'replaced' }), false, 'Original submission time cannot change');
await expectResult(await write(owner, 'incidents/report-1', { status: 'in_progress' }), false, 'Students cannot update statuses');
await expectResult(await write(staff, 'incidents/report-1', { title: 'Changed by staff' }), false, 'Staff status permission does not allow editing another report');
await expectResult(await write(staff, 'incidents/report-1', { status: 'resolved' }), false, 'Staff cannot skip the review stage');
await expectResult(await write(staff, 'incidents/report-1', { status: 'in_progress' }), true, 'Staff starts reviewing a report');
await expectResult(await write(owner, 'incidents/report-1', { title: 'Changed after review started' }), false, 'Owner cannot edit a report under review');
await expectResult(await remove(owner, 'report-1'), false, 'Owner cannot delete a report under review');
await expectResult(await write(staff, 'incidents/report-1', { status: 'resolved' }), true, 'Staff resolves a report');
await expectResult(await write(staff, 'incidents/report-1', { status: 'submitted' }), false, 'Staff cannot reset a resolved report');
await expectResult(await write(owner, 'incidents/report-2', draft, { create: true, timestamps: ['createdAt', 'updatedAt'] }), true, 'Owner creates a report for deletion');
await expectResult(await remove(other, 'report-2'), false, 'Other students cannot delete a report');
await expectResult(await remove(staff, 'report-2'), false, 'Staff cannot delete another student report');
await expectResult(await remove(owner, 'report-2'), true, 'Owner deletes their submitted report');

for (const user of [owner, other, staff, unverified, external, null]) {
  const response = await fetch(`${base}/incidents/report-1`, { headers: user ? { Authorization: `Bearer ${user.token}` } : {} });
  const allowed = [owner, other, staff].includes(user);
  const record = await expectResult(response, allowed, allowed ? 'Campus member reads the resolved report' : 'Unauthorized report read is denied');
  if (allowed) {
    assert.equal(record.fields.status.stringValue, 'resolved');
    assert.equal(record.fields.title.stringValue, 'Leaking tap near stairs');
  }
}
console.log('All Firestore access-control checks passed.');
