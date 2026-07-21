# LENS Mobile Architecture

## Direction

The Flutter Android application is a client of the Laravel 13 REST API. It uses a feature-first structure and keeps framework-wide concerns inside `mobile/lib/core`.

## Boundaries

- `app/`: application composition and routing
- `core/`: configuration, networking, storage, theme and reusable infrastructure
- `features/<feature>/`: feature-owned data, domain and presentation code
- `test/`: focused unit and widget tests

## Feature structure

Create only the layers a feature needs:

```text
features/authentication/
├── data/
│   ├── authentication_api.dart
│   └── authentication_repository.dart
├── domain/
│   └── authenticated_user.dart
└── presentation/
    ├── login_controller.dart
    └── login_page.dart
```

Do not create empty layers or generic repositories without a real use case.

## API configuration

Local Android emulator:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Physical Android phone on the same network:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR-PC-IP:8000/api/v1
```

Production:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://YOUR-DOMAIN/api/v1
```

Never commit production secrets into Dart source files.
