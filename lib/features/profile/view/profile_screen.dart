
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import '../../auth/viewmodel/auth_viewmodel.dart'; 

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
     final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Tidak Diketahui';
     final authViewModel = context.read<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               const Icon(Icons.account_circle, size: 80, color: Colors.grey),
               const SizedBox(height: 16),
               Text(
                 'Email: $userEmail',
                 style: const TextStyle(fontSize: 16),
               ),
               const SizedBox(height: 32),
               ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () {
                     authViewModel.signOut();
                  },
               )
             ],
          ),
        ),
      ),
    );
  }
}