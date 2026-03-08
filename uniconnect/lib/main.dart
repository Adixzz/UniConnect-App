import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import your new meeting request screen.
// (Adjust the folder path if you didn't put it inside a 'screens' folder)
import 'screens/student/meeting_request_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to your specific Firebase project
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      // This tells the app to load your new screen immediately
      home: const MeetingRequestScreen(),
    );
  }
}
