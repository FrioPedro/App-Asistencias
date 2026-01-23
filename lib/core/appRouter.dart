import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_asistencias/domain/auth/session.dart';
import 'package:app_asistencias/ui/screens/login_screen.dart'; 
import 'package:app_asistencias/ui/screens/events_screen.dart'; 

// tu buildPage(...)
Page<void> buildPage(Widget child, GoRouterState state) => CustomTransitionPage<void>(
  key: state.pageKey,
  transitionDuration: const Duration(milliseconds: 250),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(opacity: curved, child: child);
  },
  child: child,
);

final session = Session();

final router = GoRouter(
  initialLocation: session.isLoggedIn ? '/home' : '/login',
  refreshListenable: session, // <- clave (sin providers)
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => buildPage(const LoginScreen(), state),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => buildPage(const EventsScreen(), state),
    )/*,
    
    GoRoute(
      path: '/assignments/history',
      builder: (context, state) {
        final id = state.extra as int;
        return AssignmentHistoryView(serverId: id);
      },
    ),
    // ... resto de rutas
    */
  ],
  redirect: (context, state) {
    final loggedIn = session.isLoggedIn;
    final loggingIn = state.matchedLocation == '/login';

    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/home';
    return null;
  },
);