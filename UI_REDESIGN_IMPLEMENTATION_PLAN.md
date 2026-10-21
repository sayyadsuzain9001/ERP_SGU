# SGU Student Campus UI Redesign — Implementation Plan

## Design direction from the supplied references
- Use SGU branding with the same restrained university-portal palette: white surfaces, very light grey page background, dark charcoal text, muted grey supporting text, and SGU red/pale red for active states and primary actions.
- Use a fixed desktop sidebar, compact white top bar, rounded cards, thin borders, generous whitespace, consistent icon containers, and responsive layouts.
- Keep Firestore as the live data source. GitHub hosting does not store or replace form data; the deployed app connects directly to the configured Firebase project.

## Implemented in this package
1. Updated the shared theme tokens and component defaults to unify card corners, inputs, top bar, and the SGU red palette.
2. Adjusted the app shell's desktop navigation width, active navigation shape/colour, and top bar proportions.
3. Rebuilt the student dashboard to include a large campus hero, academic overview metrics, quick-access feature cards, student-support tiles, event cards, and campus-life image panels.
4. Kept existing AppShell navigation callbacks so dashboard cards route to existing pages instead of being decorative only.
5. Kept the existing Firebase initialization, authentication gate, Firestore repositories, and security rules unchanged in this UI pass.

## Next screen-by-screen rollout
1. Shared shell and dashboard (completed in this pass).
2. Events list and event detail: image-led cards, category/date labels, registration dialog, and clear confirmation/error states.
3. Campus explorer: floor selector, map illustration, place list, and selected-place detail.
4. Campus services and request form: service cards, completion progress, sectioned fields, validation, date selection, declaration, submit/reset, and retrieve actions.
5. Request records: live Firestore stream, loading/error/empty states, responsive records table, details, and status chips.
6. Profile and timetable: profile card, academic metric cards, weekly schedule, and date planner.
7. Apply the same spacing, type scale, cards, controls, and responsive breakpoints to teacher/admin pages.
8. Test at desktop, tablet, and mobile widths; run `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter run -d windows`; then test deployed Firebase permissions and cross-device live reads.

## Verification status
- ZIP archive integrity is checked.
- Flutter/Dart SDK is not available in this packaging environment, so compile/analyzer/runtime checks have not been claimed.
- The dashboard academic values remain illustrative UI values from the existing app and must not be presented as authoritative student records until backed by trusted database data.
