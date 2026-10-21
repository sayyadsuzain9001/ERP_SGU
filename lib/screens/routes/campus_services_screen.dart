import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import 'route_widgets.dart';

class CampusServicesScreen extends StatefulWidget {
  const CampusServicesScreen({super.key});

  @override
  State<CampusServicesScreen> createState() => _CampusServicesScreenState();
}

class _CampusServicesScreenState extends State<CampusServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = MockData.i.campusServices
        .where((service) => service.name.toLowerCase().contains(query) || service.description.toLowerCase().contains(query))
        .toList();

    return RoutePageFrame(
      title: 'Campus Services',
      subtitle: 'Open a service to view details, contact information and available support.',
      actions: [
        IconButton(
          tooltip: 'Service request form',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.serviceRequest),
          icon: const Icon(Icons.assignment_outlined),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search campus services...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          RouteSectionTitle('Available Services', action: 'Request Help', onAction: () => Navigator.pushNamed(context, AppRoutes.serviceRequest)),
          const SizedBox(height: 8),
          if (services.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Center(child: Text('No campus service matches your search.')),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 154,
                  ),
                  itemBuilder: (context, index) => _serviceTile(context, services[index]),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _serviceTile(BuildContext context, CampusService service) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.pushNamed(
            context,
            AppRoutes.serviceDetail,
            arguments: service,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.red.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(service.icon, color: AppTheme.red),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(service.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 7),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}
