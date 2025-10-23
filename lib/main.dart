import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

// Import ViewModels
import 'features/tracking/viewmodel/workout_viewmodel.dart';
import 'features/exercise_selection/viewmodel/exercise_viewmodel.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/history/viewmodel/history_viewmodel.dart';

// Import Screens
import 'features/main_screen/main_screen.dart'; // Import MainScreen (yang punya navbar)
import 'features/auth/view/login_screen.dart';
// WorkoutTrackingScreen akan diakses dari MainScreen atau tombol +
// import 'features/workout_tracking/view/workout_tracking_screen.dart'; 

const supabaseUrl = 'https://tbyjchwkedxhgkdefrco.supabase.co';
const supabaseKey = String.fromEnvironment('SUPABASE_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
     await sb.Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
  } catch (e) { print("Error initializing services: $e"); }

  runApp(
    MultiProvider( // MultiProvider di level tertinggi
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        StreamProvider<fb.User?>.value( // StreamProvider untuk status auth
          value: fb.FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        ChangeNotifierProvider(create: (context) => WorkoutViewModel()),
        ChangeNotifierProvider(
          create: (context) => ExerciseViewModel()..fetchInitialExercises(),
        ),
        ChangeNotifierProvider(create: (context) => HistoryViewModel()), // HistoryViewModel tetap di sini
      ],
      child: const MyAppEntryPoint(),
    ),
  );
}

class MyAppEntryPoint extends StatelessWidget {
  const MyAppEntryPoint({super.key});
   @override
  Widget build(BuildContext context) {
    // MaterialApp membungkus AuthWrapper
    return MaterialApp(
       debugShowCheckedModeBanner: false,
       title: 'GymBros',
       theme: ThemeData( /* ... Theme sama ... */
         primarySwatch: Colors.blue,
         visualDensity: VisualDensity.adaptivePlatformDensity,
         inputDecorationTheme: const InputDecorationTheme(
             border: OutlineInputBorder(),
             contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
             style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
             )
          )
       ),
       home: const AuthWrapper(), // Titik masuk tetap AuthWrapper
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
   @override
  Widget build(BuildContext context) {
     // Ambil status user dari StreamProvider
     final fb.User? user = context.watch<fb.User?>();

     print("[AuthWrapper] Build method called.");
     print("[AuthWrapper] User state from provider: ${user?.uid ?? 'null'}");


     if (user != null) {
       print("[AuthWrapper] State: User logged in (${user.uid}), showing MainScreen.");
       // --- INI PERBAIKAN UTAMANYA ---
       // Jika ada user, tampilkan MainScreen (yang punya navbar)
       return const MainScreen();
       // --- AKHIR PERBAIKAN ---
     } else {
       print("[AuthWrapper] State: No user logged in, showing LoginScreen.");
       // Jika tidak ada user (null), tampilkan LoginScreen
       return const LoginScreen();
     }
  }
}

