import 'package:bl_crm_poc_app/pages/dashboard_page.dart';
import 'package:bl_crm_poc_app/pages/splash_page.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static final routes = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/', builder: (context, state) => SplashPage()),
      GoRoute(path: '/dashboard', builder: (context, state) => DashboardPage()),
    ],
  );
}
