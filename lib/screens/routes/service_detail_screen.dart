import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import 'route_widgets.dart';

class ServiceDetailScreen extends StatelessWidget {
  final CampusService service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return RoutePageFrame(
      title: service.name,
      subtitle: service.description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 720;
                  final details = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppTheme.red.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(service.icon, color: AppTheme.red, size: 29),
                      ),
                      const SizedBox(height: 14),
                      Text(service.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(service.description, style: const TextStyle(color: AppTheme.muted, fontSize: 13, height: 1.45)),
                    ],
                  );

                  final information = Column(
                    children: [
                      DetailRow(icon: Icons.location_on_outlined, label: 'Location', value: service.location),
                      DetailRow(icon: Icons.schedule_outlined, label: 'Hours', value: service.hours),
                      DetailRow(icon: Icons.email_outlined, label: 'Email', value: service.email),
                      DetailRow(icon: Icons.phone_outlined, label: 'Phone', value: service.phone),
                    ],
                  );

                  if (!desktop) {
                    return Column(children: [details, const SizedBox(height: 20), information]);
                  }
                  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: details),
                    const SizedBox(width: 30),
                    Expanded(child: information),
                  ]);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_circle_outline, color: AppTheme.success),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Service available', style: TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(height: 3),
                        Text('You can submit a campus support request from this page.', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, AppRoutes.serviceRequest);
                  if (!context.mounted) return;
                  if (result is String && result.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                  }
                },
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Request Appointment'),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Return to Services'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
