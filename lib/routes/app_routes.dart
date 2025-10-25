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
        builder: (context, state) => NotePage(),
      ),
      
    ],
  );
}
