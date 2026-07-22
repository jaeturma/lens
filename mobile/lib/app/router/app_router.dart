import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/school_setup/presentation/school_binding_gate.dart';

abstract final class AppRoutes {
  static const foundation = '/';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.foundation,
    routes: [
      GoRoute(
        path: AppRoutes.foundation,
        builder: (context, state) => const SchoolBindingGate(),
      ),
    ],
  );
});
