import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/lens_app.dart';
import 'core/config/app_config.dart';
import 'features/push/data/firebase_background_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Skipped entirely when unconfigured (this development environment
  // included — `AppConfig.firebaseConfigured`'s own doc comment) rather
  // than calling `Firebase.initializeApp` with empty options, which would
  // just fail at runtime.
  if (AppConfig.firebaseConfigured) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: AppConfig.firebaseApiKey,
        appId: AppConfig.firebaseAppId,
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
        projectId: AppConfig.firebaseProjectId,
      ),
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  runApp(const ProviderScope(child: LensApp()));
}
