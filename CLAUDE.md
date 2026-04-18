# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app (API key required)
flutter run --dart-define-from-file=.env

# Run tests
flutter test

# Lint
flutter analyze

# Regenerate freezed models and JSON serialization
dart run build_runner build

# Release build (Android)
flutter build appbundle --release --dart-define-from-file=.env
flutter build apk --release --split-per-abi --dart-define-from-file=.env
```

Copy `.env.example` to `.env` and populate `NASA_API_KEY` before running. The app shows a configuration error screen at startup if the key is missing — there is no DEMO_KEY fallback.

## Architecture

**Entry point:** `lib/main.dart` initializes Firebase, Hive bookmarks, then mounts `ProviderScope` → `MaterialApp.router`.

**State management:** Riverpod exclusively. `flutter_bloc` is a listed dependency but not used — all state goes through providers. Repositories are exposed as Riverpod providers; pages consume them via `ConsumerWidget`.

**Routing:** GoRouter declared in `lib/app/router/app_router.dart` (exposed as `appRouterProvider`). Route path constants live in `app_routes.dart`. Most routes use `SwipeBackRoute` (in `lib/shared/navigation/`) for custom swipe-to-back behavior and custom `CustomTransitionPage` builders for fade/slide/scale transitions.

**Feature structure:** `lib/features/<feature>/` follows clean architecture:
- `data/` — models, repository implementations, remote/local data sources
- `domain/` — entities, repository interfaces, use cases
- `presentation/` — pages, widgets, providers

Current features: `apod`, `mars_rover`, `epic_earth`, `neo`, `nasa_search`, `planets_3d`, `demo`, `settings`, `splash`, `home`.

**Networking:** Two Dio instances in `lib/core/network/dio_provider.dart`:
- `nasaApiDio` — attaches `NASA_API_KEY` via interceptor, 20s timeouts, 2 retries with exponential backoff (350ms × attempt)
- `nasaMediaDio` — for `images-api.nasa.gov` (no key required)

`NasaApiClient` wraps both into typed methods.

**Error handling:** `AppException` enum (`network`, `timeout`, `unauthorized`, `serialization`, `storage`, `unknown`). Network errors are mapped via `mapNasaDioException()`. All repository methods return a `Result<T>` (`Success<T>` / `Failure`) — never throw to the presentation layer.

**Local persistence:** Hive for bookmarks (`lib/shared/bookmarks/`). `BookmarkHiveBootstrap` registers adapters and opens boxes during app init. `cached_network_image` handles HTTP image caching automatically.

**Firebase:** `cloud_firestore` stores 3D planet model URLs fetched by the `planets_3d` feature. `firebase_options.dart` is auto-generated and should not be edited manually.

**Configuration:** `lib/core/config/app_config.dart` holds all API base URLs and reads compile-time dart-defines. `AppConfig.requiresProductionConfiguration` is `true` when `NASA_API_KEY` is absent, triggering the bootstrap error screen.

## Key conventions

- **Dark-only theme.** No light mode — do not add light theme logic.
- **Motion constants** in `lib/core/constants/`: `motionFast` (220ms), `motionMedium` (380ms), `motionSlow` (520ms). Use these instead of ad-hoc durations.
- **Max-width constraints:** 1280px normal, 1180px compact. Wrap content in `ConstrainedBox` with these bounds.
- **Shared widgets** in `lib/shared/widgets/` (`SpaceScaffold`, `FrostedPanel`, `PremiumNetworkImage`, `AmbientSpaceBackground`, etc.) — use these before building new UI primitives.
- **Code generation:** Freezed models require `dart run build_runner build` after changes to `*.freezed.dart` source files.
- **External URLs** must be HTTPS — `AppConfig` validates this; do not bypass the check.
- **CI** (`.github/workflows/flutter-ci.yml`) runs `flutter analyze` and `flutter test` on every push/PR. Keep both passing.
