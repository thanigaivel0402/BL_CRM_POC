import 'package:bl_crm_poc_app/routes/app_routes.dart';
import 'package:bl_crm_poc_app/utils/app_preferences.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();

  // ✅ Initialize Firebase correctly for Web and Mobile
  if (Firebase.apps.isEmpty) {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyAc8AjDvA0x_-6Yija4KO1FRMDvjefDpRA",
          authDomain: "bl-crm-poc-2ea81.firebaseapp.com",
          projectId: "bl-crm-poc-2ea81",
          storageBucket: "bl-crm-poc-2ea81.firebasestorage.app",
          messagingSenderId: "231168504761",
          appId: "1:231168504761:web:a4be38ef30e142fd763c68",
          measurementId: "G-LYKQSZ5728",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }

    FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );

    final token = await FirebaseAppCheck.instance.getToken(true);
    print('App Check token: $token');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
      title: 'VoiceCRM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
