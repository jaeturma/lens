sealed class LoginState {
  const LoginState();
}

/// Waiting for credentials to be entered and submitted. [errorMessage] is
/// set after a login attempt failed — a safe, server-provided message
/// (see `AuthApi.login`), never raw exception detail.
class LoginIdle extends LoginState {
  const LoginIdle({this.errorMessage});

  final String? errorMessage;
}

class LoginSubmitting extends LoginState {
  const LoginSubmitting();
}
