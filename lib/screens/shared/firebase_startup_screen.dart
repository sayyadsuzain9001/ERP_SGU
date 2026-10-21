import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class FirebaseStartupScreen extends StatelessWidget {
  const FirebaseStartupScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    size: 38,
                    color: AppTheme.warning,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Firebase setup is required',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Configure this app with your Firebase project, enable Anonymous Authentication, and publish firestore.rules. Then restart the app.',
                    style: TextStyle(height: 1.5, color: AppTheme.muted),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    '$error',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Firebase setup'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
