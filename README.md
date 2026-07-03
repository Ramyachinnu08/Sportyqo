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
- **Login**: social buttons no longer fake a login into an empty, unauthenticated Home.
