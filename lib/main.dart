import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Screens
import 'screens/home_screen.dart'; 

// Services
import 'services/notifications_service.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized before Firebase or other services
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notification service
  await NotificationsService.initialize();

  // Initialize Firebase
   if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
         apiKey: "AIzaSyDMZSgnDHGkaR6_Xu-NAkYnGHYFJUO6Ya4",

        authDomain: "aquariummanager-7120f.firebaseapp.com",

        projectId: "aquariummanager-7120f",

        storageBucket: "aquariummanager-7120f.firebasestorage.app",

        messagingSenderId: "557311619117",

        appId: "1:557311619117:web:139cf6b008ccd02fbc88a4",

        measurementId: "G-PF36NN0X58",

      ),
    );
  } else {
    await Firebase.initializeApp(); // for mobile
  }

  // Launch the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aquarium Tracker',
      themeMode: ThemeMode.dark, // Always use dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          labelStyle: const TextStyle(color: Colors.tealAccent),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.teal),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        cardColor: const Color(0xFF1A1A1A),
        dialogBackgroundColor: const Color(0xFF1E1E1E),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.teal,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}