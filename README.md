# GalaxyDox

GalaxyDox is a premium NASA explorer built with Flutter. This first delivery sets up the production-minded foundation for a cinematic mobile app with clean architecture, centralized NASA API configuration, Riverpod state management, GoRouter navigation, and a polished editorial-style home screen.

## Release And Safety Highlights

- release builds require an injected `NASA_API_KEY`
- debug builds fall back to NASA's public `DEMO_KEY` only
- external links are restricted to trusted HTTPS hosts
- privacy notice, security policy, CI, and store metadata templates live in the repo for public GitHub maintenance

## Concept

The product is designed to feel like a high-end space documentary companion:

- editorial home experience with immersive NASA imagery
- dark, layered interface with refined motion and glass surfaces
- scalable feature-first architecture for APOD, Mars Rover, NEO, and media search
- centralized config so the NASA API key can be replaced without touching feature code

## Dependencies

- `flutter_riverpod`: application state management and dependency injection
- `go_router`: declarative routing with a scalable route tree
- `dio`: centralized API client and interceptors
- `cached_network_image`: performant image loading and caching
- `google_fonts`: stronger typography for a more premium visual system
- `intl`: date and number formatting for NASA data
- `freezed_annotation` and `json_annotation`: future-ready model generation
- `shared_preferences`: groundwork for favorites and simple local persistence
- `connectivity_plus`: connectivity awareness for offline handling
- `shimmer`: polished loading states
- `flutter_animate`: subtle motion and smoother perceived performance
- `build_runner`, `freezed`, `json_serializable`: code generation pipeline for upcoming feature models

## Folder Structure

```text
lib/
  app/
    app.dart
    router/
      app_router.dart
      app_routes.dart
  core/
    config/
      app_config.dart
    constants/
      app_constants.dart
    errors/
      app_exception.dart
      result.dart
    network/
      dio_provider.dart
      nasa_api_client.dart
    theme/
      app_colors.dart
      app_gradients.dart
      app_theme.dart
  features/
    apod/
      data/
      domain/
      presentation/
        pages/
          apod_page.dart
    home/
      data/
      domain/
      presentation/
        pages/
          home_page.dart
        providers/
          home_preview_provider.dart
        widgets/
          hero_feature_card.dart
          home_feature_card.dart
    mars_rover/
      data/
      domain/
      presentation/
        pages/
          mars_rover_page.dart
    nasa_search/
      data/
      domain/
      presentation/
        pages/
          nasa_search_page.dart
    neo/
      data/
      domain/
      presentation/
        pages/
          neo_page.dart
    settings/
      data/
      domain/
      presentation/
        pages/
          settings_page.dart
    splash/
      presentation/
        pages/
          splash_page.dart
  shared/
    widgets/
      ambient_space_background.dart
      coming_soon_page.dart
      frosted_panel.dart
      premium_network_image.dart
      section_heading.dart
      space_scaffold.dart
  main.dart
```

## API Key Setup

GalaxyDox reads release values from compile-time defines. The easiest local setup is an ignored `.env` file that you pass into Flutter builds.

Tracked example:

```bash
.env.example
```

Ignored local file:

```bash
.env
```

Supported keys:

1. `NASA_API_KEY`
2. `PRIVACY_POLICY_URL`
3. `SUPPORT_URL`
4. `SOURCE_CODE_URL`
5. `MARKETING_URL`

Run with an override:

```bash
flutter run --dart-define=NASA_API_KEY=your_nasa_key_here
```

Recommended release defines:

```bash
flutter build appbundle --release ^
  --dart-define-from-file=.env
```

Split-per-ABI release:

```bash
flutter build apk --release --split-per-abi ^
  --dart-define-from-file=.env
```

If no `NASA_API_KEY` is supplied, debug builds use NASA's public `DEMO_KEY` for quick testing. Release builds show a configuration-required screen instead of shipping with an embedded secret.

## Release Docs

- `docs/privacy-policy.md`
- `docs/store/release-checklist.md`
- `docs/store/play-data-safety.md`
- `docs/store/app-store-privacy.md`
- `SECURITY.md`
