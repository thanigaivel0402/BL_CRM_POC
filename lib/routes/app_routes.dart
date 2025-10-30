import 'package:bl_crm_poc_app/models/note.dart';
import 'package:bl_crm_poc_app/pages/dashboard_page.dart';
import 'package:bl_crm_poc_app/pages/google_sigin_page.dart';
import 'package:bl_crm_poc_app/pages/note_page.dart';
import 'package:bl_crm_poc_app/pages/splash_page.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static final routes = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => SplashPage()),
      GoRoute(
        path: '/note-page',
        name: "note-page",
        builder: (context, state) {
          var note = state.extra as Note;
          return NotePage(note: note);
        },
      ),
      GoRoute(path: '/dashboard', builder: (context, state) => DashboardPage()),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const GoogleSignInPage(),
      ),
    ],
  );
}
