import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:running_services_monitor/models/service_info.dart';
import 'package:running_services_monitor/screens/home_screen.dart';
import 'package:running_services_monitor/screens/about_screen.dart';
import 'package:running_services_monitor/screens/app_details_screen.dart';

/// Creates and configures the app's router with all route definitions
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const SelectionArea(child: HomeScreen()),
      ),
      GoRoute(path: '/about', name: 'about', builder: (context, state) => const AboutScreen()),
      GoRoute(
        path: '/app-details',
        name: 'app-details',
        builder: (context, state) {
          // Get the AppProcessInfo from the extra parameter
          final appInfo = state.extra as AppProcessInfo?;

          // If no appInfo is provided, return an error screen
          if (appInfo == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('App information not found')),
            );
          }

          return AppDetailsScreen(appInfo: appInfo);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Page not found: ${state.matchedLocation}')),
    ),
  );
}
