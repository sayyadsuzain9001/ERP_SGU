import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class UnknownRouteScreen extends StatelessWidget {
  final String? requestedRoute;
  final String? message;

  const UnknownRouteScreen({super.key, this.requestedRoute, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SGU Student Campus')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.red.withValues(alpha: .08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.route_outlined, color: AppTheme.red, size: 30),
                    ),
                    const SizedBox(height: 16),
                    const Text('Page Not Found', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(
                      message ?? 'The route ${requestedRoute ?? ''} could not be opened.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (route) => false),
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Back to Dashboard'),
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
}
