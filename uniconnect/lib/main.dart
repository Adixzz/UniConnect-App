import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniconnect/screens/admin_screens/admin_main_nav.dart';
import 'firebase_options.dart';
import 'screens/auth_screen/welcome_screen.dart';
import 'screens/student_screens/student_main_nav.dart';
import 'screens/lecturer_screens/lecturer_main_nav.dart';
import 'models/lecturer_model.dart';
import 'services/lecturer_database_service.dart';
import 'services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await PushNotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user == null) return const WelcomeScreen();

      final prefs = await SharedPreferences.getInstance();
      String? role = prefs.getString('user_role');

      if (role == 'admin') {
        return const AdminMainNav();
      } else if (role == 'lecturer') {
        final lecturerData = await LecturerDatabaseService().getUserData(user.uid);
        return LecturerMainNavigation(
          currentLecturer: LecturerModel.fromMap(
              lecturerData.data() as Map<String, dynamic>),
        );
      } else if (role == 'student') {
        return const StudentMainNavigation();
      } else {
        await FirebaseAuth.instance.signOut();
        return const WelcomeScreen();
      }
    } catch (e) {
      debugPrint("🚨 PERSISTENCE ERROR: $e");
      return const WelcomeScreen();
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
      ),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data ?? const WelcomeScreen();
        },
      ),
    );
  }
}