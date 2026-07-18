# Development

## Commands

```bash
flutter pub get                 # install deps
flutter run                     # run on a connected device/emulator
flutter run -d <device-id>      # target a specific device (flutter devices to list)

dart format .                   # format (CI enforces this)
flutter analyze                 # static analysis (CI enforces this)
flutter test                    # unit/widget tests (CI enforces this)

flutter build apk --release     # release APK
flutter build appbundle         # Play Store bundle
```

## Linting

`analysis_options.yaml` extends `flutter_lints` and adds:
- `directives_ordering` — imports/exports sorted & grouped
- `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`

Run `dart fix --apply` to auto-fix most lint issues.

## Branching

- **`dev`** — day-to-day work and docs. Pushing here does **not** trigger a build.
- **`main`** — pushing/merging here triggers CI (format → analyze → test → build APK).

Work on `dev`, then merge to `main` when you want a build:

```bash
git checkout dev
# ... commit work ...
git push origin dev

git checkout main
git merge dev
git push origin main            # triggers CI build
```

## CI (GitHub Actions)

`.github/workflows/build.yml` runs on push/PR to `main`:

1. Set up Flutter (stable, cached)
2. `flutter pub get`
3. `dart format --set-exit-if-changed` — fails if unformatted
4. `flutter analyze`
5. `flutter test`
6. `flutter build apk --release`
7. Upload the APK as a run **artifact**

### Getting the built APK

The APK is a **workflow artifact**, not a GitHub Release:
- Repo → **Actions** tab → click the run
- On the run **Summary** page, scroll to the bottom → **Artifacts** → `app-release-apk`

(Releases stay empty until you publish a tagged release manually.)

## Regenerating icons & splash

Edit `assets/images/logo.png` (and the transparent `logo_foreground.png`), then:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Config lives in `pubspec.yaml` under `flutter_launcher_icons:` and
`flutter_native_splash:`. The foreground image is padded to ~62% so the adaptive-icon
mask doesn't crop the ring/dots.

## App identity

- Application id: `com.sanjeevnode.authforge`
- Display name: **AuthForge** (change with `dart run rename setAppName ...`)
- minSdk: `flutter.minSdkVersion` (Flutter default 24 — satisfies secure_storage/local_auth)

## Testing against the live server

The app is offline for code generation, but you can verify TOTP correctness end-to-end:
1. Enable MFA on the Identity Server (`https://server.authforge.sanjeevnode.in`).
2. Scan the server's QR with the app.
3. The rolling code should match what the server accepts at `/api/v1/mfa/verify`.
