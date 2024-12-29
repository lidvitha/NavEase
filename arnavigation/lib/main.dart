import 'package:flutter/material.dart';
import 'admin_login.dart';
import 'admin_dashboard.dart';
import 'map_path.dart';
import 'student_registration.dart'; // Import the Student Registration screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login', // Set the initial route to the login screen
      routes: {
        '/': (context) => AdminLogin(), // Admin Login route
        '/admin_dashboard': (context) =>
            AdminDashboard(), // Admin Dashboard route
        '/map_path': (context) => MapPath(), // Map Path route
        '/student_registration': (context) =>
            StudentRegistration(), // Student Registration route
      },
    );
  }
}
