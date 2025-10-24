
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../../tracking/view/workout_tracking_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Tamu';

    return Scaffold(
      appBar: AppBar(
        title: const Text('GymBros'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome!\n$userEmail!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.fitness_center),
                label: const Text('Start a new Workout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const WorkoutTrackingScreen()),
                   );
                },
              ),
               // TODO: Tambahkan ringkasan latihan terakhir nanti
            ],
          ),
        ),
      ),
    );
  }
}