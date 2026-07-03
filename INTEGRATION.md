# Backend Integration

This app is wired to the SportyQo backend: https://github.com/dhanuvagman006/BackendSports

## 1. Start the backend

```bash
git clone https://github.com/dhanuvagman006/BackendSports.git
cd BackendSports
docker compose up --build        # API on :8080, auto-migrates and seeds demo data
```

## 2. Point the app at it

The base URL is read from a compile-time define (see `lib/services/api_client.dart`):

| Where you run the app | Command |
|---|---|
| Android emulator | `flutter run` (default `http://10.0.2.2:8080` already targets your host machine) |
| iOS simulator | `flutter run --dart-define=API_BASE_URL=http://localhost:8080` |
| Real phone (same Wi-Fi) | `flutter run --dart-define=API_BASE_URL=http://<your-computer-LAN-IP>:8080` |
| Production | `flutter build apk --dart-define=API_BASE_URL=https://api.yourdomain.com` |

Then:

```bash
flutter pub get   # picks up the new http + shared_preferences deps
flutter run
```

Android networking is already configured in `android/app/src/main/AndroidManifest.xml`:

- `<uses-permission android:name="android.permission.INTERNET"/>` — required for **release** builds (debug builds inherit it from the debug manifest, release builds do not; without it a release APK has no network at all).
- `android:usesCleartextTraffic="true"` — Android 9+ blocks plain-`http://` traffic by default, which silently broke every call to `http://10.0.2.2:8080` in dev. Keep this for development; for production point the app at an `https://` URL and you can remove it.

## 3. Demo accounts (from backend seed)

All passwords: `Password@123`

- Coach: `coach.suneeth@sportyqo.dev`
- Player: `arjun@sportyqo.dev` (Qo 742, Falcons FC)
- League join code: `482913`

## 4. What is wired to the API

| Screen | Backend call |
|---|---|
| Login | `POST /auth/login` — routes to Player/Coach home based on the **server's** role, shows API errors, spinner while pending |
| Create Account (player) | Captures name/phone/email/password into a registration draft |
| Generating Player ID | `POST /auth/register/player` — the ID shown is now the **server-generated** `SQP…` code (the old client-side random ID is gone) |
| Create Coach Account → Select Coach Sport | `POST /auth/register/coach` at the end of onboarding; shows the server-issued `SQC…` coach code |
| Join League (code entry) | `POST /leagues/join` — real code verification, "already joined" conflict handling, real league name on the success screen |
| Player Home | `GET /players/:id/home` — greeting name, player code, Qo score, active league/team, unread-notification dot |
| Coach Home | `GET /coach/dashboard` — coach name, title, academy, verified badge |
| Session | Tokens persist in `shared_preferences`; expired access tokens auto-refresh; `main()` restores the session at launch |

Everything not listed still renders its original mock data, and every wired screen **falls back to the mocks** if the backend is unreachable — so the app never breaks while you integrate.

## 5. Wiring the remaining screens

The typed client in `lib/services/sportyqo_api.dart` already has methods for the rest — follow the same pattern (fetch in `initState`, `setState` over the mock defaults):

- Performance screen → `SportyQoApi.playerPerformance()` (`qoJourney` = chart points, `recentMatches` = the cards)
- Profile screen → `SportyQoApi.playerProfile()`
- Notifications screen → `SportyQoApi.notifications()` / `markNotificationsRead()`
- Playbook → `SportyQoApi.playbook()`
- Dugout → `SportyQoApi.dugoutThreads()` / `dugoutMessages()` / `sendDugoutMessage()`
- Coach leagues / rosters → `myLeagues()`, `leagueTeams()`, `teamRoster()`
- Create League (multipart with logos) — see `POST /leagues` in the backend's `docs/API.md`

Full endpoint reference: `docs/API.md` in the backend repo.


## Profile photo uploads

`POST /me/avatar` accepts a multipart image (field `avatar`). In development,
if MinIO/S3 is not running, the backend saves files to its local `uploads/`
folder and serves them at `/uploads/...`; the app resolves those relative URLs
against `API_BASE_URL` automatically. iOS permission strings for camera and
photo library are already declared in `ios/Runner/Info.plist`; Android needs
no extra configuration (image_picker uses the system photo picker and camera
intent).
