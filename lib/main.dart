// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/pomodoro_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_navbar.dart';

void main() {
  runApp(StudyAssistantApp());
}

class StudyAssistantApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    PomodoroScreen(),
    DashboardScreen(),
    ChatbotScreen(),
    StudentDashboard(),
    ProfileScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTabTapped: onTabTapped,
      ),
    );
  }
}
