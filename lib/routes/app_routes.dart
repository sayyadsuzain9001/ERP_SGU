import 'package:flutter/material.dart';

import '../navigation/app_shell.dart';
import '../screens/forms/campus_service_request_screen.dart';
import '../screens/routes/campus_events_screen.dart';
import '../screens/routes/campus_services_screen.dart';
import '../screens/routes/event_detail_screen.dart';
import '../screens/routes/service_detail_screen.dart';
import '../screens/routes/student_profile_screen.dart';
import '../screens/routes/timetable_screen.dart';
import '../screens/routes/unknown_route_screen.dart';
import '../screens/shared/request_summary_screen.dart';
import '../models/models.dart';

class AppRoutes {
  AppRoutes._();

  static const dashboard = '/dashboard';
  static const timetable = '/timetable';
  static const services = '/services';
  static const events = '/events';
  static const profile = '/profile';
  static const serviceDetail = '/service-detail';
  static const eventDetail = '/event-detail';
  static const serviceRequest = '/service-request';
  static const requestSummary = '/request-summary';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AppShell(),
        );
      case timetable:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const TimetableScreen(),
        );
      case services:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CampusServicesScreen(),
        );
      case events:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CampusEventsScreen(),
        );
      case profile:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const StudentProfileScreen(),
        );
      case serviceDetail:
        final service = settings.arguments;
        if (service is CampusService) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => ServiceDetailScreen(service: service),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const UnknownRouteScreen(
            message:
                'A valid campus service was not supplied to Service Details.',
          ),
        );
      case eventDetail:
        final event = settings.arguments;
        if (event is CampusEventItem) {
          return PageRouteBuilder<void>(
            settings: settings,
            transitionDuration: const Duration(milliseconds: 280),
            reverseTransitionDuration: const Duration(milliseconds: 220),
            pageBuilder: (_, animation, _) => EventDetailScreen(event: event),
            transitionsBuilder: (_, animation, _, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const UnknownRouteScreen(
            message: 'A valid campus event was not supplied to Event Details.',
          ),
        );
      case serviceRequest:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CampusServiceRequestScreen(),
        );
      case requestSummary:
        final requestId = settings.arguments;
        if (requestId is String && requestId.isNotEmpty) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => RequestSummaryScreen(requestId: requestId),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const UnknownRouteScreen(
            message:
                'A valid request reference was not supplied for verification.',
          ),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => UnknownRouteScreen(requestedRoute: settings.name),
        );
    }
  }
}
