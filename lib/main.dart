import 'package:bl_crm_poc_app/routes/app_routes.dart';
import 'package:bl_crm_poc_app/utils/app_preferences.dart';
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
          apiKey: "AIzaSyCNb9hsj3s9Oo9koVqLfxgXZlLpPVn-AQU",
          authDomain: "bl-crm-poc.firebaseapp.com",
          projectId: "bl-crm-poc",
          storageBucket: "bl-crm-poc.appspot.com",
          messagingSenderId: "524871725925",
          appId: "1:524871725925:web:9ec76755c23585979de78c",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
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
