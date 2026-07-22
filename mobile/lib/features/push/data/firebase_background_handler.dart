import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/config/app_config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/storage/token_storage.dart';
import '../../sync/application/sync_engine.dart';
import '../../sync/data/sync_api.dart';

/// Registered via `FirebaseMessaging.onBackgroundMessage` in `main.dart`
/// (only when `AppConfig.firebaseConfigured`). Firebase runs this in its
/// own headless Dart isolate — separate from the running app, if any — so
/// it cannot reach the app's `ProviderContainer` and builds its own
/// `Dio`/`AppDatabase`/`SyncEngine` from scratch rather than going through
/// `dioProvider`/`appDatabaseProvider`. `@pragma('vm:entry-point')` keeps
/// Dart's tree shaker from removing a top-level function that is only
/// ever called from native code.
///
/// "Push triggers sync" (WP-07-13) covers this path too: a push arriving
/// while the app is backgrounded or fully terminated still advances the
/// local sync cursor, so the next time a guardian opens the app, whatever
/// prompted the push is already there.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final accessToken = await TokenStorage(
    const FlutterSecureStorage(),
  ).readAccessToken();
  if (accessToken == null) {
    return; // Not signed in on this device — nothing to sync as.
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    ),
  );

  final database = AppDatabase();
  try {
    await SyncEngine(SyncApi(dio), database).sync();
  } finally {
    await database.close();
  }
}
