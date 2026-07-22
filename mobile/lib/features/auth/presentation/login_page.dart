import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../application/login_controller.dart';
import '../application/login_state.dart';

/// School-bound parent login (WP-07-06): shown once a school is bound and
/// in good standing but no session exists yet. `school` is already
/// resolved locally — there is no School ID field here.
class LoginPage extends ConsumerWidget {
  const LoginPage({required this.school, super.key});

  final SchoolProfileData school;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Log in to ${school.name}')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _LoginForm(
                schoolId: school.publicId,
                errorMessage: switch (state) {
                  LoginIdle(:final errorMessage) => errorMessage,
                  LoginSubmitting() => null,
                },
                isSubmitting: state is LoginSubmitting,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm({
    required this.schoolId,
    required this.errorMessage,
    required this.isSubmitting,
  });

  final String schoolId;
  final String? errorMessage;
  final bool isSubmitting;

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    ref
        .read(loginControllerProvider.notifier)
        .login(
          schoolId: widget.schoolId,
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.person_outline,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            enabled: !widget.isSubmitting,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Email'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return 'Enter your email address.';
              }
              if (!trimmed.contains('@')) {
                return 'Enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            enabled: !widget.isSubmitting,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Password'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if ((value ?? '').isEmpty) {
                return 'Enter your password.';
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.isSubmitting ? null : _submit,
            child: widget.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Log In'),
          ),
        ],
      ),
    );
  }
}
