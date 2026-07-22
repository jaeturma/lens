import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/storage/token_storage.dart';
import 'package:mobile/features/auth/application/session_controller.dart';

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage([this._token]) : super(const FlutterSecureStorage());

  String? _token;

  @override
  Future<String?> readAccessToken() async => _token;

  @override
  Future<void> writeAccessToken(String token) async => _token = token;

  @override
  Future<void> clearAccessToken() async => _token = null;
}

void main() {
  test('build reflects that no token is stored', () async {
    final container = ProviderContainer(
      overrides: [tokenStorageProvider.overrideWithValue(_FakeTokenStorage())],
    );
    addTearDown(container.dispose);

    final session = await container.read(sessionControllerProvider.future);
    expect(session, isFalse);
  });

  test('build reflects that a token is already stored', () async {
    final container = ProviderContainer(
      overrides: [
        tokenStorageProvider.overrideWithValue(
          _FakeTokenStorage('existing-token'),
        ),
      ],
    );
    addTearDown(container.dispose);

    final session = await container.read(sessionControllerProvider.future);
    expect(session, isTrue);
  });

  test('markAuthenticated flips the state to true immediately', () async {
    final container = ProviderContainer(
      overrides: [tokenStorageProvider.overrideWithValue(_FakeTokenStorage())],
    );
    addTearDown(container.dispose);

    await container.read(sessionControllerProvider.future);
    container.read(sessionControllerProvider.notifier).markAuthenticated();

    expect(container.read(sessionControllerProvider).value, isTrue);
  });
}
