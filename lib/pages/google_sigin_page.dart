// lib/pages/google_signin_page.dart
import 'package:bl_crm_poc_app/pages/google_signin_button.dart';
import 'package:bl_crm_poc_app/utils/app_preferences.dart';
import 'package:bl_crm_poc_app/utils/assets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInPage extends StatefulWidget {
  const GoogleSignInPage({super.key});

  @override
  State<GoogleSignInPage> createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  User? user;
  bool _loading = false;
  String? _error;

  /// ✅ Cross-platform Google Sign-In (Android / iOS / Web)
  Future<void> signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      UserCredential? userCredential;

      if (kIsWeb) {
        // 🌐 Web: Use Firebase Auth popup or redirect flow
        try {
          final provider = GoogleAuthProvider();
          userCredential = await FirebaseAuth.instance.signInWithPopup(
            provider,
          );
        } catch (e) {
          debugPrint('Popup failed, trying redirect: $e');
          final provider = GoogleAuthProvider();
          await FirebaseAuth.instance.signInWithRedirect(provider);
          return; // the redirect flow will complete on reload
        }
      } else {
        // 📱 Mobile: Use google_sign_in package tokens
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return; // user cancelled

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
      }

      if (userCredential != null) {
        await AppPreferences.setLoggedIn(true);
        if (!mounted) return;
        context.go('/dashboard');
      }
    } catch (e, st) {
      debugPrint('Google sign-in failed: $e\n$st');
      if (!mounted) return;
      setState(() => _error = 'Sign in failed. Please try again.');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      await AppPreferences.setLoggedIn(false);
    } catch (e) {
      debugPrint('Sign out error: $e');
    } finally {
      if (!mounted) return;
      setState(() => user = null);
    }
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0072BC),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),

                  // Logo
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF0072BC)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(Assets.blLogo, fit: BoxFit.contain),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Welcome to VoiceCRM',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Capture, transcribe, and manage your voice notes.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  if (user != null) ...[
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(user!.photoURL ?? ''),
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(height: 8),
                    Text(user!.displayName ?? user!.email ?? ''),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loading ? null : signOut,
                      child: const Text('Sign out'),
                    ),
                  ] else
                    GoogleSignInButton(
                      onPressed: signInWithGoogle,
                      loading: _loading,
                      label: 'Sign in with Google',
                    ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
