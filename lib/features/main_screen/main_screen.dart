import 'package:flutter/material.dart';
import 'package:gymbros/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
// Import clipper
import '../../core/widgets/hexagon_clipper.dart';
// Import semua layar utama
import '../home/view/home_screen.dart';
import '../history/view/history_screen.dart';
import '../tracking/view/workout_tracking_screen.dart';
import '../streak/view/streak_screen.dart';
import '../profile/view/profile_screen.dart';
// import '../auth/viewmodel/auth_viewmodel.dart'; // Nanti untuk logout

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Index layar yang aktif (0, 1, 3, 4)

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    HistoryScreen(),
    // Index 2 dilewati karena dihandle FAB
    StreakScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
         index: _selectedIndex < 2 ? _selectedIndex : _selectedIndex -1,
         children: _widgetOptions,
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 20),
        child: SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkoutTrackingScreen()),
               );
            },
            shape: HexagonBorder(side: BorderSide(
                color: AppColors.surface,
                // --- UBAH NILAI INI ---
                width: 12, // <-- Ganti angka 3.0 ini sesuai keinginan Anda
                // --- AKHIR PERUBAHAN ---
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            elevation: 4.0,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: SizedBox( // --- Tambahkan SizedBox untuk kontrol tinggi ---
          height: 60.0, // Atur tinggi BottomAppBar secara eksplisit
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
              _buildNavItem(Icons.history_outlined, Icons.history, 'History', 1),
              const SizedBox(width: 100), // Ruang kosong untuk FAB
              _buildNavItem(Icons.local_fire_department_outlined, Icons.local_fire_department, 'Streak', 2),
              _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk membuat item navigasi
  Widget _buildNavItem(IconData iconData, IconData activeIconData, String label, int index) {
    int stateIndex = index < 2 ? index : index + 1;
    bool isSelected = _selectedIndex == stateIndex;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(stateIndex),
          // --- PERBAIKAN: Kurangi padding vertikal ---
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0), // Kurangi dari 8.0
          // --- AKHIR PERBAIKAN ---
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  isSelected ? activeIconData : iconData,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                  size: 24,
                ),
                // --- PERBAIKAN: Kurangi atau hilangkan SizedBox ---
                const SizedBox(height: 2), // Kurangi dari 4
                // --- AKHIR PERBAIKAN ---
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1, // Pastikan teks tidak wrap
                  overflow: TextOverflow.clip, // Hindari overflow teks
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

