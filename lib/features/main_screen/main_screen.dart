import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Nanti untuk logout
// Import semua layar utama
import '../home/view/home_screen.dart';
import '../history/view/history_screen.dart';
import '../tracking/view/workout_tracking_screen.dart'; // Layar tracking kita
import '../streak/view/streak_screen.dart';
import '../profile/view/profile_screen.dart';
// import '../auth/viewmodel/auth_viewmodel.dart'; // Nanti untuk logout

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Index layar yang aktif

  // Daftar layar sesuai urutan navbar (index 2 akan di-handle khusus)
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    HistoryScreen(),
    Placeholder(), // Placeholder untuk index 2 (tombol +)
    StreakScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    // Handle khusus untuk tombol tengah (+)
    if (index == 2) {
      // Langsung navigasi ke WorkoutTrackingScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WorkoutTrackingScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Tampilkan layar yang sesuai dengan index terpilih
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Icon saat aktif
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          // Item tengah sengaja dikosongi labelnya & icon berbeda
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
            label: '', // Kosongkan label
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department_outlined),
            activeIcon: Icon(Icons.local_fire_department),
            label: 'Streak',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
             activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor, // Warna item aktif
        unselectedItemColor: Colors.grey, // Warna item non-aktif
        showUnselectedLabels: true, // Tampilkan label meskipun tidak aktif
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Agar semua item terlihat
        elevation: 8.0, // Beri sedikit shadow
      ),
    );
  }
}