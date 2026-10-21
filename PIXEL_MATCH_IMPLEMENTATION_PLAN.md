# SGU Student Campus — Reference UI implementation plan

## Visual rules
- Page background `#F5F6F8`; surfaces `#FFFFFF`.
- SGU accent `#D32F2F`; dark red `#B71C1C`; pale accent `#FCECEF`.
- Primary text `#202126`; muted text `#7A8495`; borders `#E1E5EA`.
- Desktop uses a narrow left navigation, white top bar, wide page gutters, 18–24 px rounded panels, and subtle borders.
- Event cards are image-led and tall; service request fields use two columns on wider screens.
- Mobile layouts stack sections rather than squeezing desktop grids.

## Phase checklist

### Phase 1 — Shared theme, navigation and dashboard
- [x] Shared SGU red theme and clean surfaces.
- [x] Top bar and role-aware navigation retained.
- [x] Dashboard hero, overview metrics, class reminder, quick access, student support, events and campus-life sections.
- [x] Explore Campus quick action now opens the dedicated campus explorer.
- [ ] Pixel comparison at target viewport still requires a local screenshot.

### Phase 2 — Events list, event details and registration
- [x] Events list uses large image-led cards with category, date, registration badge and View Event action.
- [x] Event details has a wide hero image and event information.
- [x] Add to My Events continues saving to the signed-in user's Firestore `myEvents` collection.
- [ ] Replace shared campus hero imagery with approved, distinct SGU event images.
- [ ] Test save/read/remove with deployed Firestore rules on two sessions.

### Phase 3 — Campus explorer, floor selector and place details
- [x] Added Campus sidebar item and dedicated Campus Explorer screen.
- [x] Added Level 1–5 selector, illustrated floor-plan panel, place list and selected-place detail.
- [x] Campus explorer adapts to narrow widths.
- [ ] Floor-plan shapes and place names are illustrative; replace them with verified SGU building plans/locations before presenting as a real map.

### Phase 4 — Campus services and validated request form
- [x] Existing campus service directory retained with larger service cards.
- [x] Request form retains validation, progress summary, reset/submit flow, date/contact/urgency preferences and confirmation.
- [x] Student details render as a two-column field grid on wide layouts and stack on small layouts.
- [ ] Run every form validation and submit/reset test on Windows, web and mobile.

### Phase 5 — Live Firestore request records
- [x] Existing Firestore repositories and request-record pages retained.
- [x] Admin form records page remains linked in admin navigation.
- [ ] Deploy and verify least-privilege Firestore rules in the target Firebase project.
- [ ] Confirm a submission appears on a second browser/device and verify student isolation/admin access.

### Phase 6 — Student profile, academic metrics and timetable
- [x] Profile page reads and saves signed-in user profile data through the existing repository.
- [x] Timetable shell entry now opens the dedicated weekly timetable view rather than a generic module placeholder.
- [ ] Tune the profile card and timetable/calendar dimensions after comparing rendered screenshots.
- [ ] Use verified academic data or clearly label demo values; do not treat sample numbers as live records.

### Phase 7 — Teacher/admin screens and responsive consistency
- [x] Existing teacher/admin screen routes and role-aware navigation retained.
- [x] Shared theme applies across the app.
- [ ] Review every teacher/admin screen individually at desktop, tablet and mobile widths.
- [ ] Check every action, remove dead links and replace any remaining placeholder modules where required.

### Phase 8 — Build, analysis, Firebase and cross-device verification
- [ ] `flutter pub get`
- [ ] `flutter analyze` — resolve every error/warning.
- [ ] `flutter test`
- [ ] `flutter run -d windows` and full navigation test.
- [ ] Web build and deployed-hosting test against the configured Firebase project.
- [ ] Firestore auth/rules and cross-device read/write verification.
- [ ] Capture same-size screenshots and iterate on pixel-level spacing.

## Verification status
This update contains implementation changes for all eight areas, but it is not yet a verified pixel-for-pixel clone. The campus floor plan is illustrative, event cards currently reuse the campus image, and local Flutter build/analyzer/Firebase runtime tests have not been run in this packaging environment. Use the remaining checklist items to verify and finish those parts rather than assuming they passed.
