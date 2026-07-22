abstract final class AppConfig {
  static const appName = 'Project LENS';

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 20);

  // Firebase project options (WP-07-13), supplied the same way apiBaseUrl
  // is — via --dart-define at build time, never committed. Deliberately
  // not sourced from a `google-services.json`/Gradle plugin: passing
  // `FirebaseOptions` explicitly to `Firebase.initializeApp` needs no
  // native config file at all, so the Android build stays green in any
  // environment (this one included) where no real Firebase project has
  // been provisioned yet — the same "secrets are not committed, sourced
  // from the environment" precedent `docs/NOTIFICATIONS.md` documents for
  // `FIREBASE_CREDENTIALS` server-side.
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );

  /// False whenever any option above wasn't supplied — the normal state of
  /// this development environment (`docs/NOTIFICATIONS.md`'s "no real
  /// Firebase project or credentials exist" note applies here too). Push
  /// registration and message handling are skipped entirely rather than
  /// attempting (and failing) to initialize Firebase, so the app remains
  /// fully usable without it — the same acceptance criterion this
  /// package states for a guardian simply declining notification
  /// permission.
  static bool get firebaseConfigured =>
      firebaseApiKey.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseMessagingSenderId.isNotEmpty &&
      firebaseProjectId.isNotEmpty;
}
