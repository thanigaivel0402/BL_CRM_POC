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
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        await AppPreferences.init();

        // ✅ Handle web redirect result (if signInWithRedirect was used)
        if (kIsWeb) {
          try {
            final result = await FirebaseAuth.instance.getRedirectResult();
            if (result.user != null) {
              await AppPreferences.setLoggedIn(true);
            }
          } catch (e) {
            debugPrint('getRedirectResult error: $e');
          }
        }

        // ✅ Check login status (shared prefs or current user)
        final bool isLoggedIn =
            AppPreferences.isLoggedIn() ||
            FirebaseAuth.instance.currentUser != null;

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
            child: Image.asset(Assets.blLogo),
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
