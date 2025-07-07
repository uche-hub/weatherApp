import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:weather_app/core/constants/routes/route_path.dart';
import 'package:weather_app/features/weather/presentation/screens/home_screen.dart';

// Configures the GoRouter instance for app navigation with no transition pages.
final GoRouter router = GoRouter(
  initialLocation: RoutePath.home,
  routes: [
    GoRoute(
      path: RoutePath.home,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return const NoTransitionPage(
          child: HomeScreen(),
        );
      },
    ),
  ],
  errorPageBuilder: (context, state) => NoTransitionPage(
    child: Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.toString()}'),
      ),
    ),
  ),
);