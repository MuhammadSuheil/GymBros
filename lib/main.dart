import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'features/tracking/viewmodel/workout_viewmodel.dart';
import 'features/exercise_selection/viewmodel/exercise_viewmodel.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';

import 'features/main_screen/main_screen.dart'; // Ganti ke Home nanti
import 'features/auth/view/login_screen.dart';

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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        StreamProvider<fb.User?>.value(
          value: fb.FirebaseAuth.instance.authStateChanges(), 
          initialData: null, 
        ),
        ChangeNotifierProvider(create: (context) => WorkoutViewModel()),
        ChangeNotifierProvider(
          create: (context) => ExerciseViewModel()..fetchInitialExercises(),
        ),
      ],
      child: const MyAppEntryPoint(),
    ),
  );
}

class MyAppEntryPoint extends StatelessWidget {
  const MyAppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
       title: 'GymBros',
       theme: ThemeData( 
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
       home: const AuthWrapper(), 
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
     print("[AuthWrapper] Build method called.");
     final authViewModel = context.watch<AuthViewModel>();
     final fb.User? currentUser = authViewModel.currentUser;

     print("[AuthWrapper] User state from ViewModel: ${currentUser?.uid ?? 'null'}");
     print("[AuthWrapper] AuthViewModel State: ${authViewModel.state}");


     if (currentUser != null) {
       print("[AuthWrapper] State: User logged in (${currentUser.uid}), showing MainScreen.");
       // --- PERUBAHAN: Arahkan ke MainScreen ---
       return const MainScreen();
       // --- AKHIR PERUBAHAN ---
     } else {
       print("[AuthWrapper] State: No user logged in, showing LoginScreen.");
       return const LoginScreen();
     }
  }
}