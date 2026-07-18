# Architecture

The app follows **clean architecture**, organized **layer-first** under `lib/src/`.

## The dependency rule

```
        ┌─────────┐
        │   ui    │   Cubits, pages, widgets
        └────┬────┘
             │ depends on
        ┌────▼────┐
        │ domain  │   entities, repository interfaces, use-cases, services
        └────▲────┘   (pure Dart — depends on nothing)
             │ implements
        ┌────┴────┐
        │  data   │   datasources, models, repository implementations
        └─────────┘
```

Both `ui` and `data` depend on `domain`. `domain` depends on **nothing** app-specific.
Dependencies always point inward; nothing points out of `domain`.

## Layers in detail

### domain (pure)
- `entities/` — plain immutable objects (`OtpAccount`). Equatable, no JSON, no Flutter.
- `repositories/` — **abstract** contracts (`VaultRepository`) the data layer must fulfill.
- `usecases/` — one action each (`GetAccounts`, `AddAccountFromUri`, `AddAccountManual`,
  `DeleteAccount`). Thin wrappers over the repository; the UI's only entry point.
- `services/` — `TotpService`: RFC 6238 code generation + countdown. Isolated so the UI
  never computes codes itself.

### data
- `models/` — `OtpAccountModel extends OtpAccount`, adds `toJson`/`fromJson`.
- `datasources/` — `VaultLocalDataSource`: reads/writes the account list as JSON in
  `flutter_secure_storage`. Throws `StorageException` on failure.
- `repositories/` — `VaultRepositoryImpl`: implements the domain interface, parses
  `otpauth://` URIs, catches exceptions and returns `Either<Failure, T>`.

### ui
- `cubit/` — `VaultCubit` + `VaultState` (Equatable). Calls use-cases, emits states.
- `pages/` — `HomePage` (account list), `ScanQrPage`, `ManualEntryPage`.
- `widgets/` — `OtpCard` (rolling code + timer), `CountdownRing`.

### core (cross-cutting)
- `theme/`, `constants/` (per-screen strings), `error/` (Failure/Exception types),
  `di/` (get_it service locator).

## Data flow: adding an account by QR

```
ScanQrPage (ui)
   → VaultCubit.addFromUri(rawUri)            # ui → domain use-case
      → AddAccountFromUri(rawUri)
         → VaultRepository.addFromUri(...)     # domain interface
            → VaultRepositoryImpl              # data impl
               → parse otpauth:// URI
               → VaultLocalDataSource.writeAll # secure storage
            ← Either<Failure, OtpAccount>
      ← cubit emits loaded state
   ← HomePage rebuilds via BlocBuilder
```

Errors travel back as `Left(Failure)`; success as `Right(value)`. The cubit `.fold`s
them into `VaultState`.

## Error handling

- **data layer** throws typed exceptions (`StorageException`, `InvalidOtpUriException`).
- **repository** catches them and returns `Left(Failure)` — exceptions never leak past data.
- **cubit** folds `Either` into state; the UI shows `state.errorMessage`.

## Dependency injection

`core/di/injection.dart` registers everything in get_it at startup
(`configureDependencies()` in `main.dart`):

- singletons: `FlutterSecureStorage`, datasource, repository, use-cases
- factory: `VaultCubit` (fresh instance per screen)

Swap an implementation (e.g. a different storage backend) by changing one registration —
nothing else changes, because everything depends on the domain interface.

## Adding a new feature

1. **domain** — add the entity, extend/define a repository interface, write use-case(s).
2. **data** — add a model + datasource, implement the repository interface.
3. **ui** — add a Cubit + state, pages, widgets. Use per-screen constants for text.
4. **di** — register the new datasource/repo/usecases/cubit.
5. Update the relevant barrels (`<folder>.dart`), then the layer barrel picks them up.
