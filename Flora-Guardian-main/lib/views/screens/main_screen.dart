import 'package:flora_guardian/views/custom_widgets/custom_button_nav_bar.dart';
import 'package:flora_guardian/views/screens/alert_screen.dart';
import 'package:flora_guardian/views/screens/home_screen.dart';
import 'package:flora_guardian/views/screens/profile_screen.dart';
import 'package:flora_guardian/views/screens/scanner_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List _screens = [
    HomeScreen(),
    ProfileScreen(),
    ScannerScreen(),
    AlertScreen(),
  ];
  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomButtomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
      body: _screens[_selectedIndex],
    );
  }
}
