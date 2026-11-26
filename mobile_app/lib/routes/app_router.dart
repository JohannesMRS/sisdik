import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/change_password_screen.dart';
import '../features/auth/session_expired_screen.dart';
import '../features/main_shell_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/student/course_detail_screen.dart';
import '../features/student/assignment_detail_screen.dart';

GoRouter createAppRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth,
    redirect: (context, state) {
      final status = auth.status;
      final location = state.matchedLocation;
      if (status == AuthStatus.unknown) {
        return location == '/' ? null : '/';
      }
      if (status == AuthStatus.unauthenticated) {
        return location == '/login' || location == '/forgot-password' || location == '/session-expired' ? null : '/login';
      }
      if (status == AuthStatus.mustChangePassword) {
        return location == '/change-password' ? null : '/change-password';
      }
      if (status == AuthStatus.authenticated) {
        if (location == '/' || location == '/login' || location == '/forgot-password' || location == '/change-password') {
          return '/home';
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/change-password', builder: (context, state) => const ChangePasswordScreen()),
      GoRoute(path: '/home', builder: (context, state) => const MainShellScreen()),
      GoRoute(path: '/session-expired', builder: (context, state) => const SessionExpiredScreen()),
      GoRoute(path: '/courses/:courseId', builder: (context, state) => CourseDetailScreen(courseId: state.pathParameters['courseId']!)),
      GoRoute(path: '/assignments/:assignmentId', builder: (context, state) => AssignmentDetailScreen(assignmentId: state.pathParameters['assignmentId']!)),
    ],
  );
}
