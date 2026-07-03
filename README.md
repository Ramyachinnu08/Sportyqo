# SportyQo — Flutter App

Player/Coach sports platform. Works with the SportyQo backend:
https://github.com/dhanuvagman006/BackendSports (see `INTEGRATION.md` for setup, base-URL configuration and demo accounts).

## Run

```bash
flutter pub get
flutter run                     # Android emulator (backend on http://10.0.2.2:8080)
# iOS simulator / real device / production: see INTEGRATION.md for --dart-define=API_BASE_URL
```

## App structure

```
lib/
  services/       # ApiClient (auth/session/HTTP), SportyQoApi (typed endpoints), AuthService
  screens/
    auth/         # splash, role selection, login, registration, sport selection
    player/       # Home, Dugout, Playbook, Performance, Profile (+ Qo card, join league)
    coach/        # coach dashboard, leagues, dugout, playbook, performance, certifications
    shared/       # chat (thread list + conversation), used by Profile and Dugout messaging
  theme/          # colors and themes
```

## Recent fixes (2026-07)

- **Profile photos work end-to-end**: camera and gallery now open via `image_picker`
  and upload to `POST /me/avatar` (player *and* coach). Photos display on the Home
  top bar, Profile, the photo screen, and Dugout cards/profiles. A photo picked
  during sign-up is uploaded automatically right after the account is created.
  The backend stores files in S3/MinIO when available and transparently falls
  back to local disk (`/uploads`) in development, so it works with plain `npm start`.
- **Debug assertion fixed**: "ListTile background color or ink splashes may be
  invisible" — the coach-profile settings tiles and the sign-up date-of-birth
  tile now paint on a proper Material.
- **Sign-up date of birth actually saves**: the picker used to discard your
  selection and always show "15/08/2005"; it now stores and displays your date
  and persists it to your profile.
- **Gradle**: migrated the app to Flutter's Built-in Kotlin (removes the KGP
  deprecation warning; the remaining share_plus notice is plugin-side).
- After pulling, run `flutter pub get` (new dependency: `image_picker`).

- **Android networking**: added the `INTERNET` permission to the main manifest and enabled
  cleartext traffic — previously every API call failed silently on Android 9+ (empty Home,
  dead search, mock data everywhere) and release builds had no network at all.
- **Home**: real loading / error / retry states, pull-to-refresh, auto-login routing from the
  splash when a session exists, honest "no upcoming matches" empty state, live Qo tier and
  monthly delta, resilient network images, initials avatar instead of a stock photo.
- **Profile**: Academy Experience is now fully editable (add / edit / delete → backend),
  "Message" opens the real chat inbox, and a new "Edit Profile" sheet saves location,
  school/academy, club and bio via `PATCH /me/profile`.
- **Performance**: "This Season" dropdown now filters the Qo Journey (season / 6 / 3 months),
  "View All" opens the full match list, and the graph annotation shows the real latest score
  instead of a hard-coded "242 / 18 May".
- **Playbook**: fixed the "RIGHT OVERFLOWED BY 40 PIXELS" row; drills, strategies and notes
  open a proper detail screen instead of crashing with a red error screen (the fake video
  player crashed parsing an empty duration — now guarded for videos too).
- **Dugout**: search now queries the backend (debounced) instead of only filtering the first
  page, sport filters reload from the server, Follow actually calls the follow API (with the
  correct initial state), and the message button opens a real 1:1 chat.
- **Removed non-working features** (2nd pass): third-party login buttons (Google /
  Apple / Facebook) on the login and both sign-up screens; the fake "Forgot
  Password" sheet (no email/SMS delivery is configured yet); the decorative
  coach OTP screens (enter mobile → verification sent → access code) — coach
  sign-up now goes straight to profile completion; dead buttons across the app
  (playbook Like/Save/More row, chat attachment + menu icons, "Mark as
  Completed", QR scanner icon, extra share option, fake bookmark toggle) and
  the fake Dark Mode setting. The sign-up Location field, gender, notification
  setting and the Dugout share button are now actually wired to the backend
  instead of being placeholders.

## Enabling CI

The GitHub Actions workflow lives at `ci/github-actions-ci.yml`. Move it to enable analyze/test/build on every push:

```bash
mkdir -p .github/workflows && git mv ci/github-actions-ci.yml .github/workflows/ci.yml
git commit -m "Enable CI" && git push
```
