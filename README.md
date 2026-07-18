# AuthForge — Authenticator App

Flutter mobile app for AuthForge: an **offline TOTP authenticator** (like Google
Authenticator). Scans QR codes, stores secrets in encrypted local storage, and
generates rolling 6-digit codes — with **no network dependency** for day-to-day use.

Part of the AuthForge ecosystem (Identity Server + Web Portal + this app). The app
only ever talks to the server for the one-time QR scan; code generation is fully local.

---

## Stack

| Concern | Choice |
|---|---|
| Architecture | Clean architecture (domain / data / ui), layer-first |
| State management | Bloc / Cubit + Equatable |
| Dependency injection | get_it |
| Error handling | dartz `Either<Failure, T>` |
| HTTP (server feature, later) | dio |
| QR scanning | mobile_scanner |
| Secure storage | flutter_secure_storage |
| Biometric/PIN lock | local_auth |
| TOTP math | otp (RFC 6238) |

---

## Getting started

```bash
flutter pub get
flutter run
```

Requires Flutter 3.35+. Camera permission is needed for QR scanning (already
declared in the Android manifest).

---

## Architecture

Clean architecture with dependencies pointing **inward**:

```
ui  ──►  domain  ◄──  data
         (pure)
```

- **domain** — pure Dart. Entities, repository *interfaces*, use-cases, TOTP service.
  No Flutter, no packages beyond equatable/dartz. Depends on nothing.
- **data** — implements domain's interfaces. Secure-storage datasource, models
  (JSON), `otpauth://` URI parser. Returns `Either<Failure, T>`.
- **ui** — Cubits + pages + widgets. Talks only to domain use-cases, never to
  storage directly.

The rule: `ui → domain ← data`. If you find yourself importing `data` from `ui`,
that's the smell — go through a use-case.

### Layer-first structure

```
lib/
├── main.dart                    # entry: DI init + runApp
└── src/
    ├── app.dart                 # MaterialApp, theme, home
    ├── src.dart                 # top-level barrel
    ├── core/                    # shared: theme, constants, error, DI
    │   ├── constants/           # per-screen string constants (no hardcoded UI text)
    │   ├── di/                  # get_it service locator
    │   ├── error/               # Failure / Exception types
    │   └── theme/               # AppColors, AppTheme (60-30-10 palette)
    ├── domain/
    │   ├── entities/            # OtpAccount
    │   ├── repositories/        # VaultRepository (abstract)
    │   ├── services/            # TotpService (RFC 6238 math)
    │   └── usecases/            # GetAccounts, AddAccountFromUri, ...
    ├── data/
    │   ├── datasources/         # VaultLocalDataSource (secure storage)
    │   ├── models/              # OtpAccountModel (JSON)
    │   └── repositories/        # VaultRepositoryImpl
    └── ui/
        ├── cubit/               # VaultCubit + VaultState
        ├── pages/               # HomePage, ScanQrPage, ManualEntryPage
        └── widgets/             # OtpCard, CountdownRing
```

### Barrels

Every folder has a `<foldername>.dart` barrel; each layer barrel re-exports its
folder barrels; `src.dart` re-exports the layers. Import from a barrel, not a file:

```dart
import 'package:authforge/src/core/core.dart';
import 'package:authforge/src/domain/domain.dart';
```

All internal imports use `package:authforge/...` form (not relative `../../`), so
files can move without breaking imports.

---

## Conventions

- **No hardcoded UI strings** — every user-facing label lives in
  `core/constants/<screen>_constants.dart` (e.g. `HomeConstants.title`).
- **TOTP math is isolated** in `TotpService` — the UI never computes codes directly,
  so it stays testable and swappable.
- **Secrets** go through `flutter_secure_storage` only, never shared_preferences.
- **Theme:** Material 3 dark, 60-30-10 palette — `#2E2B4E` (surface), `#AA7DE4`
  (primary), `#52F9AB` (accent/success/countdown).

---

## Design assets

Logo + icons + splash are generated from `assets/images/logo.png`
(`logo_foreground.png` is the transparent, safe-zone-padded version for adaptive icons).

```bash
dart run flutter_launcher_icons        # regenerate launcher icons
dart run flutter_native_splash:create  # regenerate splash
```

App id: `com.sanjeevnode.authforge` · Display name: **AuthForge**

---

## Documentation

- [docs/architecture.md](docs/architecture.md) — layers, data flow, adding a feature
- [docs/development.md](docs/development.md) — commands, branching, CI, releasing

---

## CI

GitHub Actions (`.github/workflows/build.yml`) runs on push/PR to `main`:
format check → analyze → test → build release APK (uploaded as a run **artifact**,
not a Release). Download it from the workflow run's Summary page → Artifacts.
Work on `dev`; merge to `main` to trigger a build.
