import 'package:flutter/material.dart';
import 'home_placeholder_screen.dart';
import 'courses_placeholder_screen.dart';
import 'profile_placeholder_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int index = 0;
  final pages = const [HomePlaceholderScreen(), CoursesPlaceholderScreen(), ProfilePlaceholderScreen()];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: pages[index],
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => setState(() => index = value),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Courses'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    ),
  );
}
