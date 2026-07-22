import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/application/session_controller.dart';
import '../features/sync/application/sync_engine.dart';
import 'router/app_router.dart';

class LensApp extends ConsumerStatefulWidget {
  const LensApp({super.key});

  @override
  ConsumerState<LensApp> createState() => _LensAppState();
}

/// "Trigger sync on ... resume" (WP-07-13) — a `WidgetsBindingObserver` is
/// the plain Flutter way to detect the app returning to the foreground; no
/// push/Firebase involvement is needed for this particular trigger, so it
/// applies unconditionally (foreground/background sync triggers, by
/// contrast, only fire when Firebase is configured — see
/// `PushSyncTriggerController`).
class _LensAppState extends ConsumerState<LensApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    // Skipped before login — nothing meaningful to sync yet, and
    // `SyncApi` would just fail unauthenticated.
    if (ref.read(sessionControllerProvider).value != true) {
      return;
    }

    unawaited(_resumeSync());
  }

  Future<void> _resumeSync() async {
    try {
      await ref.read(syncEngineProvider).sync();
    } catch (_) {
      // Best-effort — see `SyncEngine`'s own doc comment: a failed resume
      // sync just leaves the cursor where the last successful one left it.
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Project LENS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
