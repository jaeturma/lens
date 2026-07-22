import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The installed app's own version (`docs/api/SCHOOL-RESOLVER.md`'s
/// "prompt an upgrade when the installed app version is below
/// minimum_app_version" — this is what gets compared against that field).
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});
