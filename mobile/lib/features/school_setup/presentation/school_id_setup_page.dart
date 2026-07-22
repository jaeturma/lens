import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_error_view.dart';
import '../application/school_id_setup_controller.dart';
import '../application/school_id_setup_state.dart';
import '../data/resolved_school.dart';

/// First-launch entry point (`docs/ARCHITECTURE.md` First Launch flow):
/// enter a School ID, confirm the resolved school, and persist the binding.
/// Shown only while no school is bound locally — see the school-binding
/// gate that renders this page.
class SchoolIdSetupPage extends ConsumerWidget {
  const SchoolIdSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(schoolIdSetupControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Set Up Your School')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: switch (state) {
                SchoolIdSetupIdle() => _SchoolIdForm(
                  errorMessage: state.errorMessage,
                ),
                SchoolIdSetupResolving() => const _SchoolIdForm(
                  isSubmitting: true,
                ),
                SchoolIdSetupResolved() => _ResolvedSchoolCard(
                  school: state.school,
                  isConfirming: false,
                ),
                SchoolIdSetupConfirming() => _ResolvedSchoolCard(
                  school: state.school,
                  isConfirming: true,
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SchoolIdForm extends ConsumerStatefulWidget {
  const _SchoolIdForm({this.errorMessage, this.isSubmitting = false});

  final String? errorMessage;
  final bool isSubmitting;

  @override
  ConsumerState<_SchoolIdForm> createState() => _SchoolIdFormState();
}

class _SchoolIdFormState extends ConsumerState<_SchoolIdForm> {
  static final _schoolIdPattern = RegExp(r'^[A-Za-z0-9-]{1,64}$');

  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    ref
        .read(schoolIdSetupControllerProvider.notifier)
        .resolve(_controller.text.trim());
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
            Icons.school_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Enter your School ID',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            "Your school provided a School ID when you registered. "
            "You'll only need to enter it once.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _controller,
            enabled: !widget.isSubmitting,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'School ID',
              hintText: 'SCH-0001',
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return 'Enter your School ID.';
              }
              if (!_schoolIdPattern.hasMatch(trimmed)) {
                return 'That doesn\'t look like a valid School ID.';
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
                : const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _ResolvedSchoolCard extends ConsumerWidget {
  const _ResolvedSchoolCard({required this.school, required this.isConfirming});

  final ResolvedSchool school;
  final bool isConfirming;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              school.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              school.schoolId,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (school.maintenanceMode) ...[
              const SizedBox(height: 16),
              AppErrorView(
                message:
                    school.maintenanceMessage ??
                    'This school is currently under maintenance.',
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Is this your school? You won\'t be asked again after confirming.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isConfirming
                  ? null
                  : () => ref
                        .read(schoolIdSetupControllerProvider.notifier)
                        .confirm(),
              child: isConfirming
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: isConfirming
                  ? null
                  : () => ref
                        .read(schoolIdSetupControllerProvider.notifier)
                        .editAgain(),
              child: const Text('Not your school'),
            ),
          ],
        ),
      ),
    );
  }
}
