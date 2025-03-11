import 'package:flutter/material.dart';

class CustomButtomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomButtomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      currentIndex: currentIndex,
      selectedIconTheme: const IconThemeData(color: Colors.black, size: 30),
      unselectedIconTheme: const IconThemeData(
        size: 30,
        color: Color.fromARGB(255, 169, 155, 149),
      ),
      selectedLabelStyle: const TextStyle(
        fontSize: 10,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 10,
        color: Colors.black,
        
      ),
      onTap: onTap,
      
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner_rounded),
          label: 'Scanner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Alert',
        ),
      ],
    );
  }
}
