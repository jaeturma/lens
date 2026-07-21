# Architecture

## Components

1. Laravel 13 web administration and REST API
2. MySQL source database
3. Flutter Android parent application
4. Drift SQLite local database
5. RFID readers
6. Firebase Cloud Messaging

## First Launch

Install -> enter School ID -> Laravel resolves school -> store immutable school UUID and profile -> lock school binding -> show login.

## Runtime Data Flow

Laravel incremental sync -> repository -> one SQLite transaction -> save cursor -> reactive SQLite query -> Flutter UI.

Flutter screens do not use network responses as their primary view model.

## RFID Flow

Reader -> authenticated raw scan endpoint -> immutable raw scan -> attendance processor -> attendance event and daily summary -> notification record -> optional push signal -> mobile sync -> SQLite -> UI.

## Push Flow

Push contains a small event hint or identifier. Flutter then synchronizes the authoritative record from Laravel.

## Binding Rules

- One installation is bound to one school.
- A locked binding is never re-requested; School ID entry is skipped on every
  launch after successful first-launch binding.
- Logout does not clear the binding.
- No in-app school reset exists; switching to a different school without
  uninstalling is not supported (see `docs/PROJECT-SCOPE.md` Excluded).
- Uninstall/reinstall resets binding.
- Android backup rules must prevent restoration of the school binding and SQLite database.
