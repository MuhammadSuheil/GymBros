import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gymbros/core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:intl/date_symbol_data_local.dart';

import 'core/services/notification_service.dart';

import 'features/tracking/viewmodel/workout_viewmodel.dart';
import 'features/exercise_selection/viewmodel/exercise_viewmodel.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/history/viewmodel/history_viewmodel.dart';
import 'features/streak/viewmodel/streak_viewmodel.dart';

import 'features/main_screen/main_screen.dart'; 
import 'features/auth/view/login_screen.dart';

const supabaseUrl = 'https://tbyjchwkedxhgkdefrco.supabase.co';
const supabaseKey = String.fromEnvironment('SUPABASE_KEY');

final NotificationService notificationService = NotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('en_US', null);
  await notificationService.initNotifications();

  try {
     await sb.Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
  } catch (e) { print("Error initializing services: $e"); }

  runApp(
    MultiProvider( 
      providers: [
        Provider<NotificationService>.value(value: notificationService),
        StreamProvider<fb.User?>.value( 
          value: fb.FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ), 
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => WorkoutViewModel()),
        
        ChangeNotifierProvider(
          create: (context) => ExerciseViewModel()..fetchInitialExercises(),
        ),
        ChangeNotifierProvider(create: (context) => HistoryViewModel()),
        ChangeNotifierProvider(create: (context) => StreakViewModel()),
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
       theme: AppTheme.darkTheme,
       home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
   @override
  Widget build(BuildContext context) {
     final fb.User? user = context.watch<fb.User?>();

     print("[AuthWrapper] Build method called.");
     print("[AuthWrapper] User state from provider: ${user?.uid ?? 'null'}");


     if (user != null) {
       print("[AuthWrapper] State: User logged in (${user.uid}), showing MainScreen.");
       return const MainScreen();
     } else {
       print("[AuthWrapper] State: No user logged in, showing LoginScreen.");
       return const LoginScreen();
     }
  }
}

