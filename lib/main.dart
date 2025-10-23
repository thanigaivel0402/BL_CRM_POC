import 'package:bl_crm_poc_app/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCNb9hsj3s9Oo9koVqLfxgXZlLpPVn-AQU",
      authDomain: "bl-crm-poc.firebaseapp.com",
      projectId: "bl-crm-poc",
      storageBucket: "bl-crm-poc.firebasestorage.app",
      messagingSenderId: "524871725925",
      appId: "1:524871725925:web:9ec76755c23585979de78c",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
