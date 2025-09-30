# Copilot Instructions for smart_login

## Project Overview
- This is a cross-platform Flutter app (see `lib/`, `android/`, `ios/`, `web/`, etc.) for smart login functionality.
- Main entry point: `lib/main.dart`.
- Core business logic is organized in `lib/api/`, `lib/providers/`, `lib/services/`, and `lib/screens/`.

## Architecture & Patterns
- **API communication**: Handled via `lib/api/api_service.dart` and `lib/services/api_service.dart`. Endpoints are defined in `lib/services/endpoints.dart`.
- **State management**: Uses provider pattern (`lib/providers/auth_provider.dart`).
- **Screen navigation**: Screens are in `lib/screens/`, with subfolders for feature grouping (e.g., `mantenimiento/`).
- **Platform support**: Android, iOS, web, Windows, macOS, Linux (see respective folders for platform-specific code).

## Developer Workflows
- **Build**: Use `flutter build <platform>` (e.g., `flutter build apk`, `flutter build web`).
- **Run**: Use `flutter run` for local development.
- **Test**: Run widget tests in `test/widget_test.dart` with `flutter test`.
- **Dependencies**: Managed via `pubspec.yaml` and `pubspec.lock`. Use `flutter pub get` to install.

## Conventions & Practices
- **File organization**: Business logic and UI are separated by feature and concern.
- **API endpoints**: Centralized in `lib/services/endpoints.dart` for maintainability.
- **Provider usage**: All authentication logic is in `lib/providers/auth_provider.dart`.
- **No custom build scripts**: Standard Flutter commands are used.
- **No custom rules files found**: Follow standard Dart/Flutter conventions unless codebase shows otherwise.

## Integration Points
- **Shared Preferences**: Uses `shared_preferences_android` (see `build/` and `android/` for generated code).
- **External packages**: Refer to `pubspec.yaml` for dependencies.

## Key Files & Directories
- `lib/main.dart`: App entry point.
- `lib/api/`, `lib/services/`, `lib/providers/`, `lib/screens/`: Core logic and UI.
- `test/widget_test.dart`: Example widget test.
- `pubspec.yaml`: Dependency management.
- Platform folders: `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`.

## Example Patterns
- API call: See `api_service.dart` for HTTP request structure.
- State update: See `auth_provider.dart` for provider usage.
- Screen navigation: See `home_screen.dart` and `login_screen.dart` for navigation logic.

---
If any section is unclear or missing, please provide feedback to improve these instructions.
