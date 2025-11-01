// lib/pages/splash_page.dart
import 'package:bl_crm_poc_app/utils/app_preferences.dart';
import 'package:bl_crm_poc_app/utils/assets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        // small pause for UX
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;

        // 1) Initialize local prefs first (avoid races)
        try {
          await AppPreferences.init();
        } catch (e) {
          debugPrint('AppPreferences.init() failed: $e');
        }

        // 2) On web, resolve any pending redirect result BEFORE checking currentUser
        if (kIsWeb) {
          try {
            final result = await FirebaseAuth.instance.getRedirectResult();
            if (result.user != null) {
              // Optionally update local prefs when redirect sign-in succeeded
              try {
                await AppPreferences.setLoggedIn(true);
              } catch (e) {
                debugPrint('Failed to set logged in pref: $e');
              }
            }
          } catch (e) {
            debugPrint('getRedirectResult error: $e');
          }
        }

        // 3) Final auth check
        final user = FirebaseAuth.instance.currentUser;
        final bool isLoggedIn =
            (AppPreferences.isLoggedIn() ?? false) || user != null;

        // navigate accordingly
        if (!mounted) return;
        if (isLoggedIn) {
          context.go('/dashboard');
        } else {
          context.go('/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              Assets.blLogo,
              width: 140,
              height: 140,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
