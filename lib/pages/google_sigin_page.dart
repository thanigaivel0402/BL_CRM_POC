// lib/pages/google_signin_page.dart
import 'package:bl_crm_poc_app/pages/google_signin_button.dart';
import 'package:bl_crm_poc_app/utils/app_preferences.dart';
import 'package:bl_crm_poc_app/utils/assets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleSignInPage extends StatefulWidget {
  const GoogleSignInPage({super.key});

  @override
  State<GoogleSignInPage> createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  User? user;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;

    // If already signed in, redirect to dashboard immediately (post frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = FirebaseAuth.instance.currentUser;
      if (current != null) {
        // ensure we don't try to navigate if widget is disposed
        if (mounted) {
          context.go('/dashboard');
        }
      }
    });
  }

  /// Cross-platform Google Sign-In (Android / iOS / Web)
  Future<void> signInWithGoogle() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      UserCredential? userCredential;

      // web flow
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        try {
          userCredential =
              await FirebaseAuth.instance.signInWithPopup(provider);
        } catch (e) {
          // fallback to redirect (popup blocked or not available)
          debugPrint('Popup failed, trying redirect: $e');
          try {
            await FirebaseAuth.instance.signInWithRedirect(provider);
            // When using redirect, the app will leave and return later.
            // Do not set _loading=false here because redirect navigates away.
            return;
          } catch (e2) {
            debugPrint('Redirect also failed: $e2');
            throw Exception('Google sign-in popup/redirect failed: $e2');
          }
        }
      } else {
        // mobile flow
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          // user cancelled
          if (!mounted) return;
          setState(() {
            _loading = false;
          });
          return;
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      // If we have a signed-in firebase user, perform allowlist check
      if (userCredential != null) {
        final firebaseUser = userCredential.user;
        if (firebaseUser == null) {
          throw Exception('No Firebase user after sign-in.');
        }

        final firestore = FirebaseFirestore.instance;

        // 1) Check allowed_users by UID
        final uidDoc =
            await firestore.collection('allowed_users').doc(firebaseUser.uid).get();
        bool allowed = uidDoc.exists;

        // 2) fallback: allowed_emails document keyed by email
        if (!allowed) {
          final email = firebaseUser.email;
          if (email != null && email.isNotEmpty) {
            final emailDoc =
                await firestore.collection('allowed_emails').doc(email).get();
            allowed = emailDoc.exists;
          }
        }

        if (!allowed) {
          // not authorized -> sign out & show message
          await signOut();

          if (!mounted) return;
          setState(() {
            _error =
                'Access denied. This app is for internal users only. Please contact admin.';
            _loading = false;
          });
          return;
        }

        // allowed -> optionally create/update user doc (merge)
        try {
          await firestore.collection('users').doc(firebaseUser.uid).set({
            'displayName': firebaseUser.displayName,
            'email': firebaseUser.email,
            'photoURL': firebaseUser.photoURL,
            'lastSeen': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('Failed to write user doc: $e');
        }

        // mark local prefs and navigate
        try {
          await AppPreferences.setLoggedIn(true);
        } catch (e) {
          debugPrint('Failed to set logged in pref: $e');
        }

        if (!mounted) return;
        setState(() {
          user = firebaseUser;
          _loading = false;
        });

        context.go('/dashboard');
        return;
      }

      // if we reach here and no userCredential (unexpected), show error
      if (!mounted) return;
      setState(() {
        _error = 'Sign in failed. Please try again.';
      });
    } catch (e, st) {
      debugPrint('Google sign-in failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = 'Sign in failed. Please try again.';
      });
    } finally {
      // If a redirect was triggered we returned earlier; otherwise ensure loading is false
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        try {
          await GoogleSignIn().signOut();
        } catch (e) {
          debugPrint('GoogleSignIn().signOut error: $e');
        }
      }
      await FirebaseAuth.instance.signOut();
      await AppPreferences.setLoggedIn(false);
    } catch (e) {
      debugPrint('Sign out error: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        user = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0072BC),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                      child: Image.asset(
                        Assets.blLogo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Welcome to VoiceCRM',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      backgroundImage: (user!.photoURL != null &&
                              user!.photoURL!.isNotEmpty)
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      backgroundColor: Colors.grey[200],
                      child: (user!.photoURL == null ||
                              user!.photoURL!.isEmpty)
                          ? Text(
                              (user!.displayName != null &&
                                      user!.displayName!.isNotEmpty)
                                  ? user!.displayName!.substring(0, 1).toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20),
                            )
                          : null,
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
