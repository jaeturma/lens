import 'package:flutter/material.dart';

/// A full block on further app use — for the two school-status conditions
/// `docs/api/SCHOOL-RESOLVER.md`'s Client Responsibility section calls out
/// as blocking: `mobile_enabled` false, and the installed version falling
/// below `minimum_app_version`. Unlike the maintenance notice (which is
/// informational only), there is nothing to fall through to here.
class SchoolStatusBlockedPage extends StatelessWidget {
  const SchoolStatusBlockedPage({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.block,
                  size: 56,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
