import 'package:go_router/go_router.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/sections/screens/sections_dashboard_screen.dart';
import '../../features/warranty_claims/screens/warranty_claims_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String sections = '/sections';
  static const String warrantyClaims = '/warranty-claims';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: sections,
        name: 'sections',
        builder: (context, state) => const SectionsDashboardScreen(),
      ),
      GoRoute(
        path: warrantyClaims,
        name: 'warranty-claims',
        builder: (context, state) => const WarrantyClaimsScreen(),
      ),
    ],
  );
}
