import 'package:flutter/material.dart';
import 'screens/auth/welcome_screen.dart';
import 'firebase_options.dart'; // This import will finally work!
import 'package:firebase_core/firebase_core.dart'; // 1. Add this import
import 'screens/student/student_home.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  // 3. Connect to your specific Firebase project
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
      ),
      home: const StudentHome(),
    );
  }
}