import 'package:flutter/material.dart';
import 'home_page.dart';
import 'matches_page.dart';
import 'swipe_page.dart';
import 'profile_page.dart';
import 'about_page.dart';

class MainNavWrapper extends StatefulWidget {
  const MainNavWrapper({super.key});

  @override
  State<MainNavWrapper> createState() => _MainNavWrapperState();
}

class _MainNavWrapperState extends State<MainNavWrapper> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) return; 
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const MatchesPage(),
      const SizedBox(), 
      const ProfilePage(),
      const AboutPage(),
    ];

    return Scaffold(
      // --- PERBAIKAN UTAMA DISINI ---
      // Mencegah FAB dan BottomNavBar naik saat keyboard muncul
      resizeToAvoidBottomInset: false, 
      
      body: _selectedIndex == 2 
          ? const SwipePage() 
          : pages[_selectedIndex],
      
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF00C853),
          shape: const CircleBorder(),
          elevation: 4,
          onPressed: () {
            setState(() {
              _selectedIndex = 2; 
            });
          },
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03), 
              spreadRadius: 1,
              blurRadius: 20, 
              offset: const Offset(0, -5), 
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.white, 
          surfaceTintColor: Colors.white, 
          elevation: 0, 
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          height: 80, 
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.list, "Matches", 1),
              const SizedBox(width: 40), 
              _buildNavItem(Icons.person, "Profile", 3),
              _buildNavItem(Icons.info_outline, "About", 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color color = isSelected ? const Color(0xFF00C853) : Colors.grey;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24, 
            ),
            const SizedBox(height: 2), 
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}