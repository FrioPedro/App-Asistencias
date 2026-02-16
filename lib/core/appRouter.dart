import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_asistencias/domain/auth/session.dart';
import 'package:app_asistencias/ui/screens/login_screen.dart';
import 'package:app_asistencias/ui/screens/home/attendance_screen.dart';
import 'package:app_asistencias/ui/screens/history_screen.dart';
import 'package:app_asistencias/ui/screens/reminder_screen.dart';

// tu buildPage(...)
Page<void> buildPage(Widget child, GoRouterState state) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(opacity: curved, child: child);
      },
      child: child,
    );

// Al eliminar 'final session = Session();', usamos la instancia global importada arriba
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
      //path: '/home2',
      
      name: 'home',
      pageBuilder: (context, state) =>
          buildPage(const AttendanceScreen(), state),
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      pageBuilder: (context, state) => buildPage(const HistoryScreen(), state),
    ),
    GoRoute(
      //path: '/home',
      path: '/reminder',
      name: 'reminder',
      pageBuilder: (context, state) {
        final message = state.uri.queryParameters['message'] ?? 'Recordatorio';
        final idStr = state.uri.queryParameters['id'];
        final id = idStr != null ? int.tryParse(idStr) : null;

        return buildPage(
          ReminderScreen(
            message: message,
            notificationId: id,
          ),
          state,
        );
      },
    ), /*,
    
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
    final isReminder = state.matchedLocation.startsWith('/reminder');

    // Permitir pantalla de recordatorio sin autenticación
    if (isReminder) return null;

    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/reminder';
    return null;
  },
);
